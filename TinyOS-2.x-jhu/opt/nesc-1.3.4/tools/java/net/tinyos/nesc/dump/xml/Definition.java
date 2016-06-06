// $Id: Definition.java,v 1.10 2010/03/23 21:15:34 idgay Exp $
/* 
  This file is provided under a dual BSD/GPLv2 license.  When using or 
  redistributing this file, you may do so under either license.

  GPL LICENSE SUMMARY

  Copyright(c) 2004-2005 Intel Corporation. All rights reserved.

  This program is free software; you can redistribute it and/or modify 
  it under the terms of version 2 of the GNU General Public License as
  published by the Free Software Foundation.

  This program is distributed in the hope that it will be useful, but 
  WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
  General Public License for more details.

  You should have received a copy of the GNU General Public License 
  along with this program; if not, write to the Free Software 
  Foundation, Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
  The full GNU General Public License is included in this distribution 
  in the file called LICENSE.GPL.

  Contact Information:
   David Gay, david.e.gay@intel.com
   Intel Labs Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 94704

  BSD LICENSE 

  Copyright(c) 2004-2005 Intel Corporation. All rights reserved.
  All rights reserved.

  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions 
  are met:

    * Redistributions of source code must retain the above copyright 
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in 
      the documentation and/or other materials provided with the 
      distribution.
    * Neither the name of Intel Corporation nor the names of its 
      contributors may be used to endorse or promote products derived 
      from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
@Copyright (c) 2005 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the
above copyright notice and the following two paragraphs appear in all
copies of this software.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.

                                                PT_COPYRIGHT_VERSION_2
                                                COPYRIGHTENDKEY


*/

package net.tinyos.nesc.dump.xml;

import org.xml.sax.*;
import java.util.*;

/**
 * Base class for objects representing definitions of nesC objects
 * (typedefs, variables, components, etc). A particular kind of nesC
 * object is represented by two elements: a definition element (e.g.,
 * "interface") and a reference element (e.g., "interface-ref"). For
 * every nesC object Y, there is at most one definition element,
 * and an arbitrary number of reference elements. All elements for Y
 * resolve to the same Java object.
 * <p>
 * toString() returns a user-friendly name for the represented nesC object
 *
 * @author contributor: Elaine Cheong <celaine@cvs.sourceforge.net>
 */

abstract public class Definition extends NDElement
{
    /**
     * true if the definition element for this nesC object has been
     * seen. Fields are marked with (definition only) if they are only
     * defined once the definition is available.
     */
    public boolean definitionAvailable;

    /** (definition only) The attributes on this nesC object */
    public LinkedList/*Xattribute_value*/ attributes;

    /** (definition only) The source code location where this object
       is defined. May be null. */
    public Location location;

    /**
     * init is called when the first element for this nesC object is seen
     * (it may be a reference or a definition element).
     * @param attrs Attributes from the first definition or reference element.
     */
    public void init(Attributes attrs) {
	location = Location.decode(attrs.getValue("loc"));
    }

    /**
     * addNewAttributes can be called at any time to add new
     * attributes.  Does not ovewrite existing attributes.
     * @param attrs Attributes from the current definition or reference element.
     */
    public void addNewAttributes(Attributes attrs) {
        if (location == null) {
            location = Location.decode(attrs.getValue("loc"));
        }
    }

    public void child(NDElement subElement) {
	if (subElement instanceof Xattribute_value) {
	    if (attributes == null)
		attributes = new LinkedList();
	    attributes.add(subElement);
	}
    }

    /**
     * Lookup a nesC attribute by name.
     * @param name Name of attriute to find.
     * @return An attribute in the attributes list with the specified
     *   name, or null if none is found.
     */
    public Xattribute_value attributeLookup(String name) {
	if (attributes == null)
	    return null;

	ListIterator elems = attributes.listIterator();

	while (elems.hasNext()) {
	    Xattribute_value attr = (Xattribute_value)elems.next();
	    Xattribute a = attr.attribute;
	    String n = a.name;

	    if (n.equals(name))
		return attr;
	}
	return null;
    }
}
