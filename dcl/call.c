/*
================================================================================
  DCL/2 version 1.00
  	Digital Command Language

    Date de cr�ation    : 28 novembre 2001

    Tous droits r�serv�s � l'auteur, Jo�l BERTRAND
	All rights reserved worldwide
================================================================================
*/


/*
================================================================================
  Copyright (C) 2001 BERTRAND Jo�l

  This file is part of DCL/2.

  DCL/2 is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the
  Free Software Foundation; either version 2, or (at your option) any
  later version.
            
  DCL/2 is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
  for more details.
              
  You should have received a copy of the GNU General Public License
  along with Octave; see the file COPYING.  If not, write to the Free
  Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
================================================================================
*/


#include "dcl.h"

int
call(dcl$arg *arg, dcl$env *env)
{
	char			**qualifiers;

	dcl$arg			*current;

	int				i;
	int				number_of_qualifiers;
	int				status;

	pid_t			pid;

	number_of_qualifiers = 0;
	current = arg;

	while(current != NULL)
	{
		number_of_qualifiers++;
		current = (*current).next;
	}

	if ((qualifiers = malloc((number_of_qualifiers + 1) *
			sizeof(unsigned char *))) == NULL)
	{
		return(DCL$FAILURE);
	}

	for(qualifiers[number_of_qualifiers] = NULL,
			current = arg, i = number_of_qualifiers - 1; i >= 0; i--)
	{
		qualifiers[i] = (*current).argument;
		current = (*current).next;
	}

	if ((pid = fork()) < 0)
	{
		return(DCL$FAILURE);
	}

	if (pid == 0)
	{
		execvp(qualifiers[0], qualifiers);
		// int execv()

		/*
		 * Child process has returned an error.
		 */

		return(DCL$FAILURE);
	}
	else
	{
		if (waitpid(pid, &status, 0) == -1)
		{
			return(DCL$FAILURE);
		}
	}

	free(qualifiers);
	return(DCL$SUCCESS);
}
