// $Id: WiringNode.java,v 1.7 2010/03/23 21:15:34 idgay Exp $
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

package net.tinyos.nesc.dump.xml;

import java.util.*;

/**
 * A node in a wiring graph.
 * @see net.tinyos.nesc.dump.xml.WiringGraph
 * @see net.tinyos.nesc.dump.xml.Xwire
 * @see net.tinyos.nesc.dump.xml.WiringEndpoint
 */
public class WiringNode
{
    static LinkedList/*Xwire*/ empty = new LinkedList();

    LinkedList/*Xwire*/ outgoing, incoming;

    /**
     * The definition this node is for.
     */
    public DataDefinition ep;

    WiringNode(DataDefinition ep) {
	this.ep = ep;
    }

    void addToEdge(Xwire e) {
	//System.err.println("" + this + " TO " + e.to);
	if (outgoing == null)
	    outgoing = new LinkedList();
	outgoing.add(e);
    }

    void addFromEdge(Xwire e) {
	//System.err.println("" + this + " FROM " + e.from);
	if (incoming == null)
	    incoming = new LinkedList();
	incoming.add(e);
    }

    /**
     * Get all outgoing edges from this node.
     * @return Outgoing edge iterator for this node.
     */
    public ListIterator/*Xwire*/ outgoingEdges() {
	if (outgoing == null)
	    return empty.listIterator();
	else
	    return outgoing.listIterator();
    }

    /**
     * Get all incoming edges from this node.
     * @return Incoming edge iterator for this node.
     */
    public ListIterator/*Xwire*/ incomingEdges() {
	if (incoming == null)
	    return empty.listIterator();
	else
	    return incoming.listIterator();
    }

    public String toString() {
	//return "(@" + super.toString() + ")node:" + ep;
	return "node:" + ep;
    }
}
