// $Id$
// $Locker$

// Author. Roar Thron�s.
// Modified Linux source file, 2001-2006  

/* Written 2000 by Andi Kleen */
/* This program is never executed, just its assembly is examined for offsets 
   (this trick is needed to get cross compiling right) */  
/* $Id$ */
#define ASM_OFFSET_H 1
#ifndef __KERNEL__
#define __KERNEL__ 
#endif
#include <linux/sched.h> 
#include <linux/stddef.h>
#include <linux/errno.h> 
#include <asm/pda.h>
#include <asm/hardirq.h>
#include <asm/processor.h>
#include <asm/desc.h>
#include <cpudef.h>

#define output(x) asm volatile ("--- " x)
#define outconst(x,y) asm volatile ("--- " x : : "i" (y)) 

int main(void) 
{ 
	output("/* Auto generated by arch/../tools/offset.c at " __DATE__ ". Do not edit. */\n"); 
	output("#ifndef ASM_OFFSET_H\n");
	output("#define ASM_OFFSET_H 1\n"); 

	// task struct entries needed by entry.S
#define ENTRY(entry) outconst("#define tsk_" #entry " %0", offsetof(struct task_struct, entry))
	ENTRY(state);
	ENTRY(flags); 
	ENTRY(sigpending); 
	ENTRY(addr_limit); 
	ENTRY(need_resched); 
	ENTRY(exec_domain); 
	ENTRY(ptrace); 
#if 0
	ENTRY(processor);
#endif
	ENTRY(need_resched); 
	ENTRY(thread);
	ENTRY(ipr_sp);
	ENTRY(psl);
	ENTRY(oldpsl);
	ENTRY(pcb$l_cpu_id);
#undef ENTRY
#define ENTRY(entry) outconst("#define pda_" #entry " %0", offsetof(struct x8664_pda, entry))
	ENTRY(kernelstack); 
	ENTRY(oldrsp); 
	ENTRY(pcurrent); 
	ENTRY(irqrsp);
	ENTRY(irqcount);
	ENTRY(pgd_quick);
	ENTRY(pmd_quick);
	ENTRY(pte_quick);
	ENTRY(pgtable_cache_sz);
	ENTRY(cpunumber);
	ENTRY(irqstackptr);
	ENTRY(level4_pgt);
#undef ENTRY
#define ENTRY(entry) outconst("#define cpu_" #entry " %0", offsetof(struct _cpu, entry))
	ENTRY(cpu$l_saved_isp);
	ENTRY(cpu$ps_pda);
#undef ENTRY
	output("#ifdef __ASSEMBLY__"); 
	outconst("#define PT_TRACESYS %0", PT_TRACESYS);
	outconst("#define TASK_SIZE %0", TASK_SIZE); 
	outconst("#define SIGCHLD %0", SIGCHLD);
	outconst("#define CLONE_VFORK %0", CLONE_VFORK); 
	outconst("#define CLONE_VM %0", CLONE_VM); 


	outconst("#define thread_flags %0" , offsetof(struct thread_struct, flags));
	outconst("#define ASM_THREAD_IA32 %0", THREAD_IA32);

	outconst("#define PER_CPU_GDT_SIZE %0", sizeof(struct per_cpu_gdt)); 
	output("#endif"); 

	output("#endif\n"); 

	return(0); 
} 

