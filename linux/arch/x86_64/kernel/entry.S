// $Id$
// $Locker$

// Author. Roar Thron�s.
// Modified Linux source file, 2001-2006  

/*
 *  linux/arch/x86_64/entry.S
 *
 *  Copyright (C) 1991, 1992  Linus Torvalds
 *  Copyright (C) 2000, 2001, 2002  Andi Kleen SuSE Labs
 *  Copyright (C) 2000  Pavel Machek <pavel@suse.cz>
 * 
 *  $Id$		
 */

/*
 * entry.S contains the system-call and fault low-level handling routines.
 *
 * NOTE: This code handles signal-recognition, which happens every time
 * after an interrupt and after each system call.
 * 
 * Normal syscalls and interrupts don't save a full stack frame, this is 
 * only done for PT_TRACESYS, signals or fork/exec et.al.
 * 
 * TODO:	 
 * - schedule it carefully for the final hardware.		 	
 *
 */

#define ASSEMBLY 1
#include <linux/config.h>
#include <linux/linkage.h>
#include <asm/segment.h>
#include <asm/current.h>	
#include <asm/smp.h>
#include <asm/cache.h>
#include <asm/errno.h>
#include <asm/calling.h>
#include <asm/offset.h>
#include <asm/msr.h>
#include <asm/unistd.h>
#include <asm/hw_irq.h>

	.code64

#define PUSHR_ALL \
	cld; \
	pushq %rax; \
	pushq %rbx; \
	pushq %rcx; \
	pushq %rdx; \
	pushq %rbp; \
	pushq %rdi; \
	pushq %rsi; \
	pushq %r8;  \
	pushq %r9;  \
	pushq %r10; \
	pushq %r11; \
	pushq %r12; \
	pushq %r13; \
	pushq %r14; \
	pushq %r15;

#define POPR_ALL	\
	popq %r15;	\
	popq %r14;	\
	popq %r13;	\
	popq %r12;	\
	popq %r11;	\
	popq %r10;	\
	popq %r9;	\
	popq %r8;	\
	popq %rsi;	\
	popq %rdi;	\
	popq %rbp;	\
	popq %rdx;	\
	popq %rcx;	\
	popq %rbx;	\
	popq %rax;

#define PUSHPSL \
        PUSHR_ALL; \
        call pushpsl; \
        POPR_ALL; 

#define PUSHPSLINTR \
        PUSHR_ALL; \
        call pushpsl; \
	call setpsli; \
        POPR_ALL; 

#define REI \
	pushq %rax		; \
	movw %cs, %ax		; \
	test $3, %ax		; \
	je 1f			; \
	int $0xb2		; \
	jmp 2f			; \
1:				; \
	cli			; \
2:				; \
	popq %rax		; \
        PUSHR_ALL		; \
        call myrei		; \
	pushfq			; \
	popq %rdi		; \
	andq $0x200, %rdi	; \
	je 111f			; \
	call panic		; \
111:				; \
        POPR_ALL

#define INTPANIC \
	pushq %rdx		; \
	pushfq			; \
	popq %rdx		; \
	andq $0x200, %rdx	; \
	je 1f			; \
	call panic		; \
1:	popq %rdx

#define RSP0PANIC \
	testq $0x8, %rsp	; \
	jne 1f			; \
	call panic		; \
1:	
			
#define RSP8PANIC \
	testq $0x8, %rsp	; \
	je 1f			; \
	call panic		; \
1:	
			
#define SYSRET_SAVE_TSS_SP \
	pushq %rdi		; \
	pushq %rdx		; \
	movq 0x7ffff000, %rdi	; \
	movq tsk_pcbl_cpu_id(%rdi), %rdx ; \
	shl $0x8, %rdx		; \
	addq $init_tss, %rdx	; \
	addq $0x4, %rdx		; /* yes, 4 */ \
	addq $tsk_ipr_sp, %rdi	; \
	movq %rsp, (%rdi)	; \
	addq $0x10, (%rdi)	; \
	movq %rsp, (%rdx)	; \
	addq $0x10, (%rdx)	; \
	movq %rsp, PDAREF(pda_kernelstack) ; \
	addq $0x10, PDAREF(pda_kernelstack) ; \
	popq %rdx		; \
	popq %rdi

#define SAVE_TSS_SP \
	pushq %rax		; \
	pushq %rdi		; \
	pushq %rdx		; \
	movq 0x7ffff000, %rdi	; \
	movq tsk_pcbl_cpu_id(%rdi), %rdx ; \
	shl $0x8, %rdx		; \
	addq $init_tss, %rdx	; \
	addq $0x4, %rdx		; /* yes, 4 */ \
	addq $tsk_ipr_sp, %rdi	; \
	mov %cs, %rax		; \
	cmpq %rax, 0x20(%rsp)	; \
	je 2f			; \
	andq $0x3, %rax		; \
	shl $0x3, %rax 		; \
	addq %rax, %rdi		; \
	addq %rax, %rdx		; \
	movq %rsp, (%rdi)	; \
	addq $0x40, (%rdi)	; \
	movq %rsp, (%rdx)	; \
	addq $0x40, (%rdx)	; \
	andq %rax, %rax		; \
	jne 4f			; \
	movq %rsp, PDAREF(pda_kernelstack) ; \
	addq $0x40, PDAREF(pda_kernelstack) ; \
4:				; \
	jmp 3f			; \
2:				; \
	andq $0x3, %rax		; \
	shl $0x3, %rax 		; \
	addq %rax, %rdi		; \
	addq %rax, %rdx		; \
	andq %rax, %rax		; \
	movq 0x30(%rsp), %rax	; \
	movq %rax, (%rdi)	; \
	movq %rax, (%rdx)	; \
	jne 4f			; \
	movq %rdi, PDAREF(pda_kernelstack) ; \
4:				; \
3:				; \
	popq %rdx		; \
	popq %rdi		; \
	popq %rax

/* also need to do stack changes */
/* and astlvl checks */
  
#define PDAREF(field) %gs:field	 		

/*
 * C code is not supposed to know about partial frames. Everytime a C function
 * that looks at the pt_regs is called these two macros are executed around it.
 * RESTORE_TOP_OF_STACK syncs the syscall state after any possible ptregs
 * manipulation.
 */        	
		
	/* %rsp:at FRAMEEND */ 
	.macro FIXUP_TOP_OF_STACK tmp
	movq	PDAREF(pda_oldrsp),\tmp
	movq  	\tmp,RSP(%rsp)
	movq    $__USER_DS,SS(%rsp)
	movq    $__USER_CS,CS(%rsp)
	movq	$-1,RCX(%rsp)	/* contains return address, already in RIP */
	movq	R11(%rsp),\tmp  /* get eflags */
	movq	\tmp,EFLAGS(%rsp)
	.endm

	.macro RESTORE_TOP_OF_STACK tmp,offset=0
	movq   RSP-\offset(%rsp),\tmp
	movq   \tmp,PDAREF(pda_oldrsp)
	movq   EFLAGS-\offset(%rsp),\tmp
	movq   \tmp,R11-\offset(%rsp)
	.endm

	.macro regtrapi type,param
	pushq %rax
	pushq %rcx
	pushq %rdx
	pushq %rdi
	pushq %rsi
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	movq \type, %rdi
	movq \param, %rsi
	call regtrap
	call setpsli
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rsi
	popq %rdi
	popq %rdx
	popq %rcx
	popq %rax
	.endm
	
	.macro save_sp x
	pushq %rax
	pushq %rdi
	pushq %rdx
	movq 0x7ffff000, %rdi
	movq tsk_pcbl_cpu_id(%rdi), %rdx
	shl $0x8, %rdx
	addq $init_tss, %rdx
	addq $0x4, %rdx
	addq $tsk_ipr_sp, %rdi
	movq \x+0x20(%rsp), %rax
	andq $0x3, %rax
	je 2f 
	salw $3,%ax
	addq %rax, %rdi
	addq %rax, %rdx
	cmpq $0x18, %rax
	movq \x+0x30(%rsp),%rax
	je 4f
	jmp 3f
2:	
	andq %rax, %rax
	movq \x+0x30(%rsp), %rax
	jne 3f
	movq %rax, PDAREF(pda_kernelstack)
3:	
	movq %rax, (%rdx)
4:			
	movq %rax, (%rdi)
	popq %rdx
	popq %rdi
	popq %rax
	.endm
	
	.macro syscall_save_sp x
	pushq %rdi
	movq 0x7ffff000, %rdi
	addq $tsk_ipr_sp, %rdi
	addq $0x18, %rdi
	movq %rsp, (%rdi)
	addq $0x08, (%rdi)
	popq %rdi
	.endm
	
/*
 * A newly forked process directly context switches into this.
 */ 	
ENTRY(ret_from_fork)
	PUSHPSL	// check. temp workaround
	movq %rax,%rdi		/* return value of __switch_to -> prev task */
#	call schedule_tail
	GET_CURRENT(%rcx)
	testb $PT_TRACESYS,tsk_ptrace(%rcx)
	jnz 2f
1:
	RESTORE_REST
	testl $3,CS-ARGOFFSET(%rsp) # from kernel_thread?
	jz   int_ret_from_sys_call
	testl $ASM_THREAD_IA32,tsk_thread+thread_flags(%rcx)
	jnz  int_ret_from_sys_call
	RESTORE_TOP_OF_STACK %rdi,ARGOFFSET
	jmp ret_from_sys_call
2:
	movq %rsp,%rdi	
	call syscall_trace
	GET_CURRENT(%rcx)
	jmp 1b

/*
 * System call entry. Upto 6 arguments in registers are supported.
 *
 * SYSCALL does not save anything on the stack and does not change the
 * stack pointer. Gets the per CPU area from the hidden GS MSR and finds the
 * current kernel stack.
 */
		
/*
 * Register setup:	
 * rax  system call number
 * rdi  arg0
 * rcx  return address for syscall/sysret, C arg3 
 * rsi  arg1
 * rdx  arg2	
 * r10  arg3 	(--> moved to rcx for C)
 * r8   arg4
 * r9   arg5
 * r11  eflags for syscall/sysret, temporary for C
 * r12-r15,rbp,rbx saved by C code, not touched. 		
 * 
 * Interrupts are off on entry.
 * Only called from user space.	
 */ 			 		

ENTRY(system_call)
#	subq $0x8, %rsp
#	movq %rcx, (%rsp)
#	movq $exe$syscall, %rcx
#	sysretq
	swapgs
	syscall_save_sp 0	
	movq	%rsp,PDAREF(pda_oldrsp) 
	movq	PDAREF(pda_kernelstack),%rsp
#if 0
	movq 0x7ffff000, %rsp
	movq tsk_pcbl_cpu_id(%rsp), %rsp
	shl $0x8, %rsp
	addq $init_tss, %rsp
	addq $0x4, %rsp
	movq (%rsp), %rsp
#endif		
	RSP8PANIC
	regtrapi $1,$0
	sti
	SAVE_ARGS 8,1
	movq  %rax,ORIG_RAX-ARGOFFSET(%rsp) 
	movq  %rcx,RIP-ARGOFFSET(%rsp)	
	GET_CURRENT(%rcx)
	testl $PT_TRACESYS,tsk_ptrace(%rcx)
	jne tracesys
	cmpq $__NR_syscall_max,%rax
	ja badsys
	movq %r10,%rcx
	call *sys_call_table(,%rax,8)  # XXX:	 rip relative
	movq %rax,RAX-ARGOFFSET(%rsp)
	.globl ret_from_sys_call
ret_from_sys_call:	
sysret_with_reschedule:
	GET_CURRENT(%rcx)
	cli 
	cmpl $0,tsk_sigpending(%rcx)
	jne sysret_signal
sysret_restore_args:
	movq    RIP-ARGOFFSET(%rsp),%rcx
	RESTORE_ARGS 0,8,1 # was -ARG_SKIP, caused no rsp change and overflow
	REI
	INTPANIC
	SYSRET_SAVE_TSS_SP
	movq	PDAREF(pda_oldrsp),%rsp
	swapgs
	sysretq
	
sysret_signal:
	sti
	xorl %esi,%esi		# oldset
	leaq -ARGOFFSET(%rsp),%rdi	# regs
	leaq do_signal(%rip),%rax
	call ptregscall_common	
sysret_signal_test:
	cli
	jmp sysret_restore_args
	
tracesys:			 
	SAVE_REST
	movq $-ENOSYS,RAX(%rsp)
	FIXUP_TOP_OF_STACK %rdi
	movq %rsp,%rdi
	call syscall_trace
	LOAD_ARGS ARGOFFSET  /* reload args from stack in case ptrace changed it */
	RESTORE_REST
	cmpq $__NR_syscall_max,%rax
	ja  tracesys_done
tracesys_call:		/* backtrace marker */		
	movq %r10,%rcx	/* fixup for C */
	call *sys_call_table(,%rax,8)
	movq %rax,RAX-ARGOFFSET(%rsp)
tracesys_done:		/* backtrace marker */	
	SAVE_REST
	movq %rsp,%rdi
	call syscall_trace
	RESTORE_TOP_OF_STACK %rbx
	RESTORE_REST
	jmp ret_from_sys_call
		
badsys:
	movq $0,ORIG_RAX-ARGOFFSET(%rsp)
	movq $-ENOSYS,RAX-ARGOFFSET(%rsp)
	jmp ret_from_sys_call

/*
 * Syscall return path ending with IRET.
 * This can be either 64bit calls that require restoring of all registers 
 * (impossible with sysret) or 32bit calls. 	 
 */	
ENTRY(int_ret_from_sys_call)	
intret_test_kernel:
	testl $3,CS-ARGOFFSET(%rsp)		
	je retint_restore_args
intret_with_reschedule:
	GET_CURRENT(%rcx)
	cli 
	cmpl $0,tsk_sigpending(%rcx)
	jne intret_signal
	jmp retint_restore_args_swapgs
	
intret_signal:
	sti
	SAVE_REST
	xorq %rsi,%rsi		# oldset -> arg2 
	movq %rsp,%rdi		# &ptregs -> arg1		
	call do_signal
	RESTORE_REST
intret_signal_test:		
	cli
	jmp retint_restore_args_swapgs
	
/* 
 * Certain special system calls that need to save a complete stack frame.
 */ 								
	
	.macro PTREGSCALL label,func
	.globl \label
\label:
	leaq	\func(%rip),%rax
	jmp	ptregscall_common
	.endm

	PTREGSCALL stub_clone, sys_clone
	PTREGSCALL stub_fork, sys_fork
	PTREGSCALL stub_vfork, sys_vfork
	PTREGSCALL stub_rt_sigsuspend, sys_rt_sigsuspend
	PTREGSCALL stub_sigaltstack, sys_sigaltstack

	.macro PTREGSCALL3 label,func,arg
	.globl \label
\label:
	leaq	\func(%rip),%rax
	leaq    -ARGOFFSET+8(%rsp),\arg /* 8 for return address */
	jmp	ptregscall_common
	.endm

	PTREGSCALL3 stub_iopl, sys_iopl, %rsi

ENTRY(ptregscall_common)
	popq %r11
	SAVE_REST
	movq %r11, %r15
	FIXUP_TOP_OF_STACK %r11
	call *%rax
	RESTORE_TOP_OF_STACK %r11
	movq %r15, %r11
	RESTORE_REST
	pushq %r11
	ret
	
ENTRY(stub_execve)
	popq %r11
	SAVE_REST
	movq %r11, %r15
	FIXUP_TOP_OF_STACK %r11
	call sys_execve
	GET_CURRENT(%rcx)
	testl $ASM_THREAD_IA32,tsk_thread+thread_flags(%rcx)
	jnz exec_32bit
	RESTORE_TOP_OF_STACK %r11
	movq %r15, %r11
	RESTORE_REST
	push %r11
	ret

exec_32bit:
	movq %rax,RAX(%rsp)
	RESTORE_REST
	jmp int_ret_from_sys_call
	
/*
 * sigreturn is special because it needs to restore all registers on return.
 * This cannot be done with SYSRET, so use the IRET return path instead.
 */                
ENTRY(stub_rt_sigreturn)
	addq $8, %rsp		
	SAVE_REST
	FIXUP_TOP_OF_STACK %r11
	call sys_rt_sigreturn
	movq %rax,RAX(%rsp) # fixme, this could be done at the higher layer
	RESTORE_REST
	jmp int_ret_from_sys_call

/* 
 * Interrupt entry/exit.
 *
 * Interrupt entry points save only callee clobbered registers, except
 * for signals again.
 *	
 * Entry runs with interrupts off.	
 */ 

/* 0(%rsp): interrupt number */ 
ENTRY(common_interrupt)
	RSP8PANIC
	testl $3,16(%rsp)	# from kernel?
	je   1f
	swapgs
1:	cld
	save_sp 8
#ifdef CONFIG_X86_REMOTE_DEBUG
	SAVE_ALL
	movq %rsp, %rdi
#else			
	SAVE_ARGS
	leaq -ARGOFFSET(%rsp),%rdi	# arg1 for handler
#endif
	regtrapi $0,$0x10
	pushq %rdi
	call do_IRQ
	popq %rdi
	/* 0(%rsp): oldrsp-ARGOFFSET */ 
ENTRY(ret_from_intr)
	cli
	testl $3,CS(%rdi)	# from kernel?
	je	retint_restore_args
	/* Interrupt came from user space */
retint_with_reschedule:
	GET_CURRENT(%rcx)
	cmpl $0,tsk_sigpending(%rcx)
	jne retint_signal
retint_restore_args_swapgs:		
	RESTORE_ARGS 0,8						
	REI
	INTPANIC
	SAVE_TSS_SP
	swapgs
	jmp iret_label
retint_restore_args:				
	RESTORE_ARGS 0,8						
	REI
	INTPANIC
	SAVE_TSS_SP
iret_label:
	iretq
	.section __ex_table,"a"
	.align 8
	.quad iret_label,bad_iret
	.previous
	.section .fixup,"ax"
	/* force a signal here? this matches i386 behaviour */
bad_iret:
	/* runs with kernelgs again */	
	movq $-9999,%rdi	/* better code? */
	jmp do_exit			
	.previous	

retint_signal:	
	sti
	SAVE_REST
	movq $-1,ORIG_RAX(%rsp) 			
	xorq %rsi,%rsi		# oldset
	movq %rsp,%rdi		# &pt_regs
	call do_signal
	RESTORE_REST
retint_signal_test:		
	cli
	jmp retint_restore_args_swapgs

ENTRY(exe_sti)
	orl $0x200, 0x10(%rsp)
	iretq
				
ENTRY(exe_cli)
	andl $0xfffffdff, 0x10(%rsp)
	iretq
				
ENTRY(vms_system_call0)
	RSP0PANIC
	testl $3,8(%rsp)	# from kernel?
	je   1f
	swapgs
1:
	save_sp 0	
	regtrapi $1,$0
	sti
	SAVE_ARGS 8,0
	movq  %rax,ORIG_RAX-ARGOFFSET(%rsp)
#if 0	
	movq  %rcx,RIP-ARGOFFSET(%rsp)
#endif	
	GET_CURRENT(%rcx)
	testl $PT_TRACESYS,tsk_ptrace(%rcx)
	jne vms_tracesys
	cmpq $__NR_syscall_max,%rax
	ja vms_badsys
	movq %r10,%rcx
	call *sys_call_table(,%rax,8)  # XXX:	 rip relative
	jmp vms_syscall_common
	
ENTRY(vms_system_call3)
	RSP0PANIC
	testl $3,8(%rsp)	# from kernel?
	je   1f
	swapgs
1:
	save_sp 0	
	regtrapi $1,$3
	sti
	SAVE_ARGS 8,0
	movq  %rax,ORIG_RAX-ARGOFFSET(%rsp)
#if 0	
	movq  %rcx,RIP-ARGOFFSET(%rsp)
#endif	
	GET_CURRENT(%rcx)
	testl $PT_TRACESYS,tsk_ptrace(%rcx)
	jne vms_tracesys
	cmpq $__NR_syscall_max,%rax
	ja vms_badsys
	movq %r10,%rcx
	call *vms_sys_call_table3(,%rax,8)  # XXX:	 rip relative
	jmp vms_syscall_common
	
ENTRY(vms_system_call1)
	RSP0PANIC
#if 0	
	testl $3,8(%rsp)	# from kernel?
	je   1f
	swapgs
1:
#endif	
	save_sp 0	
	regtrapi $1,$1
	int $0xb3
	SAVE_ARGS 8,0
	movq  %rax,ORIG_RAX-ARGOFFSET(%rsp)
#if 0
	movq  %rcx,RIP-ARGOFFSET(%rsp)
#endif	
	GET_CURRENT(%rcx)
	testl $PT_TRACESYS,tsk_ptrace(%rcx)
	jne vms_tracesys
	cmpq $__NR_syscall_max,%rax
	ja vms_badsys
	movq %r10,%rcx
	call *vms_sys_call_table1(,%rax,8)  # XXX:	 rip relative
	jmp vms_syscall_common
	
ENTRY(vms_system_call)
	RSP0PANIC
	testl $3,8(%rsp)	# from kernel?
	je   1f
	swapgs
1:
	save_sp 0	
	regtrapi $1,$0
	sti
	SAVE_ARGS 8,0 # was:	8,1 
	movq  %rax,ORIG_RAX-ARGOFFSET(%rsp)
#if 0
	movq  %rcx,RIP-ARGOFFSET(%rsp)
#endif	
	GET_CURRENT(%rcx)
	testl $PT_TRACESYS,tsk_ptrace(%rcx)
	jne vms_tracesys
	cmpq $__NR_syscall_max,%rax
	ja vms_badsys
	movq %r10,%rcx
	call *vms_sys_call_table(,%rax,8)  # XXX:	 rip relative
vms_syscall_common:	
	movq %rax,RAX-ARGOFFSET(%rsp)
	.globl vms_ret_from_sys_call
vms_ret_from_sys_call:	
vms_iret_with_reschedule:
	GET_CURRENT(%rcx)
	movw %cs, %ax
	test $3, %ax
	je 1f
	int $0xb2
	jmp 2f
1:
	cli				# need_resched and signals atomic test
2:
	cmpl $0,tsk_sigpending(%rcx)
	jne vms_iret_signal
vms_iret_restore_args:
	RESTORE_ARGS 0,8
	REI	
	INTPANIC
	SAVE_TSS_SP
	pushq %rax
	movw %cs, %ax
	cmpw $0x41, %ax
	popq %rax
	je 1f
	testl $3,8(%rsp)	# from kernel?
	je   1f
	swapgs
1:
	iretq
			
vms_iret_signal:
	sti
	xorl %esi,%esi		# oldset
	leaq -ARGOFFSET(%rsp),%rdi	# regs
	leaq do_signal(%rip),%rax
	call vms_ptregscall_common	
vms_iret_signal_test:
	cli
	jmp vms_iret_restore_args
	
vms_tracesys:			 
	SAVE_REST
	movq $-ENOSYS,RAX(%rsp)
	FIXUP_TOP_OF_STACK %rdi
	movq %rsp,%rdi
	call syscall_trace
	LOAD_ARGS ARGOFFSET  /* reload args from stack in case ptrace changed it */
	RESTORE_REST
	cmpq $__NR_syscall_max,%rax
	ja  vms_tracesys_done
vms_tracesys_call:		/* backtrace marker */		
	movq %r10,%rcx	/* fixup for C */
	call *vms_sys_call_table(,%rax,8)
	movq %rax,RAX-ARGOFFSET(%rsp)
vms_tracesys_done:		/* backtrace marker */	
	SAVE_REST
	movq %rsp,%rdi
	call syscall_trace
	RESTORE_TOP_OF_STACK %rbx
	RESTORE_REST
	jmp vms_ret_from_sys_call
		
vms_badsys:
	movq $0,ORIG_RAX-ARGOFFSET(%rsp)
	movq $-ENOSYS,RAX-ARGOFFSET(%rsp)
	jmp vms_ret_from_sys_call

/* 
 * Certain special system calls that need to save a complete stack frame.
 */ 								
	
	.macro VMS_PTREGSCALL label,func
	.globl \label
\label:
	leaq	\func(%rip),%rax
	jmp	vms_ptregscall_common
	.endm

	VMS_PTREGSCALL vms_stub_clone, sys_clone
	VMS_PTREGSCALL vms_stub_fork, sys_fork
	VMS_PTREGSCALL vms_stub_vfork, sys_vfork
	VMS_PTREGSCALL vms_stub_rt_sigsuspend, sys_rt_sigsuspend
	VMS_PTREGSCALL vms_stub_sigaltstack, sys_sigaltstack
	VMS_PTREGSCALL vms_stub_iopl, sys_iopl

ENTRY(vms_ptregscall_common)
	popq %r11
	SAVE_REST
	movq %r11, %r15
	FIXUP_TOP_OF_STACK %r11
	call *%rax
	RESTORE_TOP_OF_STACK %r11
	movq %r15, %r11
	RESTORE_REST
	pushq %r11
	ret
	
vms_exec_32bit:
	movq %rax,RAX(%rsp)
	RESTORE_REST
	jmp int_ret_from_sys_call
	
	.macro BUILD_SMP_INTERRUPT x,v
ENTRY(\x)
	push $\v-256
	RSP8PANIC
	testl $3,16(%rsp)	# from kernel?
	je   1f
	swapgs
1:	cld
	save_sp 8
	SAVE_ARGS
	leaq -ARGOFFSET(%rsp),%rdi	# arg1 for handler
	regtrapi $0,$0x10
	pushq %rdi
	call smp_\x
	popq %rdi
	jmp ret_from_intr
	.endm

#ifdef CONFIG_SMP				
	BUILD_SMP_INTERRUPT reschedule_interrupt,RESCHEDULE_VECTOR
	BUILD_SMP_INTERRUPT invalidate_interrupt,INVALIDATE_TLB_VECTOR
	BUILD_SMP_INTERRUPT call_function_interrupt,CALL_FUNCTION_VECTOR
	BUILD_SMP_INTERRUPT ipint_interrupt,IPINT_VECTOR
#endif
#ifdef CONFIG_X86_LOCAL_APIC
	BUILD_SMP_INTERRUPT apic_timer_interrupt,LOCAL_TIMER_VECTOR
	BUILD_SMP_INTERRUPT error_interrupt,ERROR_APIC_VECTOR
	BUILD_SMP_INTERRUPT spurious_interrupt,SPURIOUS_APIC_VECTOR
#endif
		
		
/*
 * Exception entry points.
 */ 		
	.macro zeroentry sym
	pushq $0	/* push error code/oldrax */ 
	pushq %rax	/* push real oldrax to the rdi slot */ 
	leaq  \sym(%rip),%rax
	jmp error_entry
	.endm	

	.macro errorentry sym
	pushq %rax
	leaq  \sym(%rip),%rax
	jmp error_entry
	.endm

	.macro softentry sym
	testl $3,8(%rsp)       # from kernel?
	je   1f
	swapgs
1:	
	save_sp 0
	PUSHR_ALL
	call \sym
	POPR_ALL
	REI
	INTPANIC
	SAVE_TSS_SP
	testl $3,8(%rsp)       # from kernel?
	je   1f
	swapgs
1:	
	iretq		
	.endm
	
/*
 * Exception entry point. This expects an error code/orig_rax on the stack
 * and the exception handler in %rax.	
 */ 		  				
 	ALIGN
error_entry:
	/* rdi slot contains rax, oldrax contains error code */
	pushq %rsi
	movq  8(%rsp),%rsi	/* load rax */
	pushq %rdx
	pushq %rcx
	pushq %rsi	/* store rax */ 
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	cld
	SAVE_REST
	xorl %r15d,%r15d	
	testl $3,CS(%rsp)
	je error_kernelspace
	swapgs	
error_action:
	save_sp 0x80
	regtrapi $0,$0x10
	movq  %rdi,RDI(%rsp) 	
	movq %rsp,%rdi
	movq ORIG_RAX(%rsp),%rsi	/* get error code */ 
	movq $-1,ORIG_RAX(%rsp)
	call *%rax
	cli				/* because of page_fault sti */
	/* r15d: swapgs flag */
error_exit:
	testl %r15d,%r15d
	jnz   error_restore
error_test:		
	cli	
	GET_CURRENT(%rcx)
	cmpl $0,tsk_sigpending(%rcx)
	jne  error_signal
error_restore_swapgs:
	REI					
	RESTORE_REST
	RESTORE_ARGS 0,8						
	INTPANIC
	SAVE_TSS_SP
	swapgs
	jmp iret_label
error_restore:	
	REI
	RESTORE_REST
	RESTORE_ARGS 0,8						
	INTPANIC
	SAVE_TSS_SP
	jmp iret_label
	
error_signal:	
	sti
	xorq %rsi,%rsi
	movq %rsp,%rdi
	call do_signal
error_signal_test:
	cli
	jmp error_restore_swapgs
	
error_kernelspace:	
	incl %r15d
	/* There are two places in the kernel that can potentially fault with
	   usergs. Handle them here. */	   
	leaq iret_label(%rip),%rdx
	cmpq %rdx,RIP(%rsp)
	je 1f
	/* check truncated address too. This works around a CPU issue */
	movl %edx,%edx	/* zero extend */
	cmpq %rdx,RIP(%rsp)
	je   1f
	cmpq $gs_change,RIP(%rsp)
	jne  error_action
	/* iret_label and gs_change are handled by exception handlers
	   and the exit points run with kernelgs again */
1:	swapgs
	jmp error_action

	/* Reload gs selector with exception handling */
	/* edi:	 new selector */ 
ENTRY(load_gs_index)
	pushf
	cli
	swapgs
gs_change:	
	movl %edi,%gs	
2:	mfence		/* workaround for opteron errata #88 */
	swapgs
	popf
	ret
	
	.section __ex_table,"a"
	.align 8
	.quad gs_change,bad_gs
	.previous

bad_gs:
	swapgs
	xorl %eax,%eax
	movl %eax,%gs
	jmp 2b
/*
 * Create a kernel thread.
 *
 * C extern interface:
 *	extern long arch_kernel_thread(int (*fn)(void *), void * arg, unsigned long flags)
 *
 * asm input arguments:
 *	rdi: fn, rsi: arg, rdx: flags
 */
ENTRY(arch_kernel_thread)
	FAKE_STACK_FRAME $child_rip
	SAVE_ALL

	# rdi: flags, rsi: usp, rdx: will be &pt_regs
	movq %rdx,%rdi
	orq  $0x00010000 /* $CLONE_VM */, %rdi

	movq $-1, %rsi

	movq %rsp, %rdx

	# clone now
	call do_fork
	# save retval on the stack so it's popped before `ret`
	movq %rax, RAX(%rsp)

	/*
	 * It isn't worth to check for reschedule here,
	 * so internally to the x86_64 port you can rely on kernel_thread()
	 * not to reschedule the child before returning, this avoids the need
	 * of hacks for example to fork off the per-CPU idle tasks.
         * [Hopefully no generic code relies on the reschedule -AK]	
	 */
	RESTORE_ALL
	UNFAKE_STACK_FRAME
	ret
	
child_rip:
	/*
	 * Here we are in the child and the registers are set as they were
	 * at kernel_thread() invocation in the parent.
	 */
	movq %rdi, %rax
	movq %rsi, %rdi
	call *%rax
	# exit
	xorq %rdi, %rdi
	call do_exit

/*
 * execve(). This function needs to use IRET, not SYSRET, to set up all state properly.
 *
 * C extern interface:
 *	 extern long execve(char *name, char **argv, char **envp)
 *
 * asm input arguments:
 *	rdi: name, rsi: argv, rdx: envp
 *
 * We want to fallback into:
 *	extern long sys_execve(char *name, char **argv,char **envp, struct pt_regs regs)
 *
 * do_sys_execve asm fallback arguments:
 *	rdi: name, rsi: argv, rdx: envp, fake frame on the stack
 */
ENTRY(execve)
	FAKE_STACK_FRAME $0
	SAVE_ALL
	PUSHPSLINTR
	call sys_execve
	movq %rax, RAX(%rsp)	
	RESTORE_REST
	testq %rax,%rax
	je int_ret_from_sys_call
	RESTORE_ARGS
	UNFAKE_STACK_FRAME
	ret

ENTRY(page_fault)
	errorentry do_page_fault

ENTRY(coprocessor_error)
	zeroentry do_coprocessor_error

ENTRY(simd_coprocessor_error)
	zeroentry do_simd_coprocessor_error	

ENTRY(device_not_available)
	pushq $-1	
	SAVE_ALL
	PUSHPSL
	xorl %r15d,%r15d
	testl $3,CS(%rsp)
	jz 1f
	swapgs 
2:	movq  %cr0,%rax
	leaq  math_state_restore(%rip),%rcx
	leaq  math_emulate(%rip),%rbx
	testl $0x4,%eax
	cmoveq %rcx,%rbx
	call  *%rbx
	jmp  error_exit
1:	incl %r15d
	jmp  2b

ENTRY(debug)
	zeroentry do_debug

ENTRY(nmi)
	pushq $-1
	SAVE_ALL
	PUSHPSL
	/* NMI could happen inside the critical section of a swapgs,
	   so it is needed to use this expensive way to check.
	   Rely on arch_prctl forbiding user space from setting a negative
	   GS. Only the kernel value is negative. */
	movl  $MSR_GS_BASE,%ecx
	rdmsr
	xorl  %ebx,%ebx
	testl %edx,%edx
	js    1f
	swapgs
	movl  $1,%ebx
1:	movq %rsp,%rdi
	call do_nmi
	cli
	testl %ebx,%ebx
	jz error_restore
	swapgs	
	jmp error_restore
	
ENTRY(int3)
	zeroentry do_int3	

ENTRY(overflow)
	zeroentry do_overflow

ENTRY(bounds)
	zeroentry do_bounds

ENTRY(invalid_op)
	zeroentry do_invalid_op	

ENTRY(coprocessor_segment_overrun)
	zeroentry do_coprocessor_segment_overrun

ENTRY(reserved)
	zeroentry do_reserved

ENTRY(double_fault)
	errorentry do_double_fault	

ENTRY(invalid_TSS)
	errorentry do_invalid_TSS

ENTRY(segment_not_present)
	errorentry do_segment_not_present

ENTRY(stack_segment)
	errorentry do_stack_segment

ENTRY(general_protection)
	errorentry do_general_protection

ENTRY(alignment_check)
	errorentry do_alignment_check

ENTRY(divide_error)
	zeroentry do_divide_error

ENTRY(spurious_interrupt_bug)
	zeroentry do_spurious_interrupt_bug

ENTRY(machine_check)
	zeroentry do_machine_check	

ENTRY(call_debug)
	zeroentry do_call_debug

ENTRY(test_code)
	softentry do_test_code
        PUSHR_ALL
        call pushpsl
        call SYMBOL_NAME(do_test_code)
        POPR_ALL
        REI

ENTRY(sched_vector)
	softentry schedule
        PUSHR_ALL
        call SYMBOL_NAME(schedule)
        POPR_ALL
        REI

ENTRY(resched_vector)
	softentry sch$resched
        PUSHR_ALL
        call SYMBOL_NAME(sch$resched)
        POPR_ALL
        REI

ENTRY(timer_vector)
	softentry exe$swtimint
        PUSHR_ALL
        call SYMBOL_NAME(exe$swtimint)
        POPR_ALL
        REI

ENTRY(timerfork_vector)
	softentry exe$swtimint
        PUSHR_ALL
        call SYMBOL_NAME(exe$swtimint)
        POPR_ALL
        REI

ENTRY(iopost_vector)
	softentry ioc$iopost
        PUSHR_ALL
        call SYMBOL_NAME(ioc$iopost)
        POPR_ALL
        REI

ENTRY(astdel_vector)
	softentry sch$astdel	
        PUSHR_ALL
        call SYMBOL_NAME(sch$astdel)
        POPR_ALL
        REI

ENTRY(queueast_vector)
	softentry exe$frkipl6dsp
        PUSHR_ALL
        call SYMBOL_NAME(exe$frkipl6dsp)
        POPR_ALL
        REI

ENTRY(iolock8_vector)
	softentry exe$frkipl8dsp
        PUSHR_ALL
        call SYMBOL_NAME(exe$frkipl8dsp)
        POPR_ALL
        REI

ENTRY(iolock9_vector)
	softentry exe$frkipl9dsp
        PUSHR_ALL
        call SYMBOL_NAME(exe$frkipl9dsp)
        POPR_ALL
        REI

ENTRY(iolock10_vector)
	softentry exe$frkipl10dsp
        PUSHR_ALL
        call SYMBOL_NAME(exe$frkipl10dsp)
        POPR_ALL
        REI

ENTRY(iolock11_vector)
	softentry exe$frkipl11dsp
        PUSHR_ALL
        call SYMBOL_NAME(exe$frkipl11dsp)
        POPR_ALL
        REI
	
ENTRY(test_exe)
	iretq

ENTRY(test_sup)
	iretq

.data
ENTRY(vms_sys_call_table)
	.quad SYMBOL_NAME(sys_$ni_syscall)	/* 0  -  old "setup()" system call*/
	.quad SYMBOL_NAME(sys_$testtest)
	.quad SYMBOL_NAME(exe$setpri_wrap)
        .quad SYMBOL_NAME(exe$crelnt_wrap)
        .quad SYMBOL_NAME(exe$setprn)
        .quad SYMBOL_NAME(exe$dclast)
        .quad SYMBOL_NAME(exe$waitfr)
        .quad SYMBOL_NAME(exe$wflor)
        .quad SYMBOL_NAME(exe$wfland)
        .quad SYMBOL_NAME(exe$clref)
        .quad SYMBOL_NAME(exe$setime)
        .quad SYMBOL_NAME(exe$setimr)
        .quad SYMBOL_NAME(exe$cantim)
        .quad SYMBOL_NAME(exe$numtim)
        .quad SYMBOL_NAME(exe$gettim)
        .quad SYMBOL_NAME(exe$hiber)
        .quad SYMBOL_NAME(exe$wake)
        .quad SYMBOL_NAME(exe$schdwk)
        .quad SYMBOL_NAME(exe$canwak)
        .quad SYMBOL_NAME(exe$suspnd)
        .quad SYMBOL_NAME(exe$resume)
        .quad SYMBOL_NAME(exe$exit)
        .quad SYMBOL_NAME(exe$forcex)
        .quad SYMBOL_NAME(exe$setrwm)
        .quad SYMBOL_NAME(exe$delprc)
        .quad SYMBOL_NAME(exe$readef)
        .quad SYMBOL_NAME(exe$setef)
        .quad SYMBOL_NAME(exe$synch)
        .quad SYMBOL_NAME(exe$enq_wrap)
        .quad SYMBOL_NAME(exe$deq)
        .quad SYMBOL_NAME(exe$assign)
        .quad SYMBOL_NAME(exe$dassgn)
        .quad SYMBOL_NAME(exe$qio_wrap)
        .quad SYMBOL_NAME(exe$qiow_wrap)
        .quad SYMBOL_NAME(exe$getlki_wrap)
        .quad SYMBOL_NAME(exe$getlkiw_wrap)
        .quad SYMBOL_NAME(exe$enqw_wrap) 
        .quad SYMBOL_NAME(exe$crelnm) 
        .quad SYMBOL_NAME(exe$trnlnm) 
        .quad SYMBOL_NAME(exe$dellnm) 
        .quad SYMBOL_NAME(exe$clrast) 
        .quad SYMBOL_NAME(exe$setast) 
        .quad SYMBOL_NAME(exe$ascefc) 
        .quad SYMBOL_NAME(exe$dacefc) 
        .quad SYMBOL_NAME(exe$dlcefc) 
        .quad SYMBOL_NAME(exe$crembx_wrap) 
        .quad SYMBOL_NAME(exe$delmbx) 
        .quad SYMBOL_NAME(exe$mount) 
	.quad SYMBOL_NAME(exe$cretva)
	.quad SYMBOL_NAME(exe$expreg)
	.quad SYMBOL_NAME(exe$crmpsc_wrap)
	.quad SYMBOL_NAME(exe$mgblsc_wrap)
	.quad SYMBOL_NAME(exe$deltva)
	.quad SYMBOL_NAME(exe$cntreg)
	.quad SYMBOL_NAME(exe$dgblsc)
	.quad SYMBOL_NAME(exe$setswm)
	.quad SYMBOL_NAME(exe$setprt)
	.quad SYMBOL_NAME(exe$adjwsl)
	.quad SYMBOL_NAME(exe$lkwset)
	.quad SYMBOL_NAME(exe$lckpag)
	.quad SYMBOL_NAME(exe$ulwset)
	.quad SYMBOL_NAME(exe$ulkpag)
	.quad SYMBOL_NAME(exe$purgws)
	.quad SYMBOL_NAME(exe$creprc_wrap          )
	.quad SYMBOL_NAME(exe$imgact_wrap          )
	.quad SYMBOL_NAME(exe$imgfix          )
	.quad SYMBOL_NAME(exe$imgsta_wrap          )
	.quad SYMBOL_NAME(exe$dclexh          )
	.quad SYMBOL_NAME(exe$rundwn          )
	.quad SYMBOL_NAME(exe$sndjbc          )
	.quad SYMBOL_NAME(exe$sndjbcw         )
	.quad SYMBOL_NAME(exe$getqui          )
	.quad SYMBOL_NAME(exe$getmsg          )
	.quad SYMBOL_NAME(exe$putmsg          )
	.quad SYMBOL_NAME(exe$excmsg          )
	.quad SYMBOL_NAME(exe$getsyi_wrap          )
	.quad SYMBOL_NAME(exe$getsyiw_wrap         )
	.quad SYMBOL_NAME(exe$device_scan     )
	.quad SYMBOL_NAME(exe$getdvi_wrap     )
	.quad SYMBOL_NAME(exe$fao             )
	.quad SYMBOL_NAME(exe$faol            )
	.quad SYMBOL_NAME(exe$cmkrnl          )
	.quad SYMBOL_NAME(exe$getjpi_wrap     )
	.quad SYMBOL_NAME(exe$updsec          )
	.quad SYMBOL_NAME(exe$resched         )
	.quad SYMBOL_NAME(exe$setexv          )
	.quad SYMBOL_NAME(exe$check_access    )
	.quad SYMBOL_NAME(exe$getuai_wrap     )
	.quad SYMBOL_NAME(exe$setuai          )
	.quad SYMBOL_NAME(exe$idtoasc         )
	.quad SYMBOL_NAME(exe$asctoid         )
	.quad SYMBOL_NAME(exe$add_ident       )
	.quad SYMBOL_NAME(exe$rem_ident       )
	.quad SYMBOL_NAME(exe$find_held       )
	.quad SYMBOL_NAME(exe$find_holder     )
	.quad SYMBOL_NAME(exe$mod_ident       )
	.quad SYMBOL_NAME(exe$mod_holder      )
	.quad SYMBOL_NAME(exe$grantid      )
	.quad SYMBOL_NAME(exe$revokid      )
	.quad SYMBOL_NAME(exe$create_region_32_wrap)
	.quad SYMBOL_NAME(exe$delete_region_32)
	.quad SYMBOL_NAME(exe$get_region_info)
	.quad SYMBOL_NAME(exe$getdviw_wrap)
	.quad SYMBOL_NAME(exe$cli)
	.quad SYMBOL_NAME(exe$setprv)
	.quad SYMBOL_NAME(exe$cancel)
	.quad SYMBOL_NAME(exe$getjpiw_wrap)
	.quad SYMBOL_NAME(exe$sndopr)
	.quad SYMBOL_NAME(exe$process_affinity_wrap)
	.quad SYMBOL_NAME(exe$set_implicit_affinity)
	.quad SYMBOL_NAME(exe$cpu_capabilities)
	.quad SYMBOL_NAME(exe$process_capabilities_wrap)
	.quad SYMBOL_NAME(exe$set_security_wrap)
	.quad SYMBOL_NAME(exe$get_security_wrap)

#	.rept NR_vmssyscalls-(.-vmssys_call_table)/8
		.quad SYMBOL_NAME(sys_$ni_syscall)

  .endr

ENTRY(vms_sys_call_table1)
        .quad SYMBOL_NAME(sys_$ni_syscall1)
	.quad SYMBOL_NAME(exe$close)
	.quad SYMBOL_NAME(exe$connect)
	.quad SYMBOL_NAME(exe$create)
	.quad SYMBOL_NAME(exe$delete)
	.quad SYMBOL_NAME(exe$disconnect)
	.quad SYMBOL_NAME(exe$display)
	.quad SYMBOL_NAME(exe$enter)
	.quad SYMBOL_NAME(exe$erase)
	.quad SYMBOL_NAME(exe$extend)
	.quad SYMBOL_NAME(exe$find)
	.quad SYMBOL_NAME(exe$flush)
	.quad SYMBOL_NAME(exe$free)
	.quad SYMBOL_NAME(exe$get)
	.quad SYMBOL_NAME(exe$modify)
	.quad SYMBOL_NAME(exe$nxtvol)
	.quad SYMBOL_NAME(exe$open)
	.quad SYMBOL_NAME(exe$parse)
	.quad SYMBOL_NAME(exe$put)
	.quad SYMBOL_NAME(exe$read)
	.quad SYMBOL_NAME(exe$release)
	.quad SYMBOL_NAME(exe$remove)
	.quad SYMBOL_NAME(exe$rename)
	.quad SYMBOL_NAME(exe$rewind)
	.quad SYMBOL_NAME(exe$search)
	.quad SYMBOL_NAME(exe$space)
	.quad SYMBOL_NAME(exe$truncate)
	.quad SYMBOL_NAME(exe$update)
	.quad SYMBOL_NAME(exe$wait)
	.quad SYMBOL_NAME(exe$write)
	.quad SYMBOL_NAME(exe$filescan)
	.quad SYMBOL_NAME(exe$setddir)
	.quad SYMBOL_NAME(exe$setdfprot)
	.quad SYMBOL_NAME(exe$ssvexc)
	.quad SYMBOL_NAME(exe$rmsrundwn)
	.quad SYMBOL_NAME(exe$cmexec)
#	.rept NR_vmssyscalls1-(.-vmssys_call_table1)/8
		.quad SYMBOL_NAME(sys_$ni_syscall1)

  .endr


ENTRY(vms_sys_call_table3)
	.quad SYMBOL_NAME(sys_$ni_syscall3)	/* 0  -  old "setup()" system call*/
        .quad SYMBOL_NAME(exe$asctim)
        .quad SYMBOL_NAME(exe$bintim)

#	.rept NR_vms_syscalls3-(.-vms_sys_call_table3)/8
		.quad SYMBOL_NAME(sys_$ni_syscall3)

  .endr



	
	
