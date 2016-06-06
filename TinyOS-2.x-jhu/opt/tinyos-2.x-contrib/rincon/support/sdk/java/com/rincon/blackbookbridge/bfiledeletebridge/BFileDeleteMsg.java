/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'BFileDeleteMsg'
 * message type.
 */

package com.rincon.blackbookbridge.bfiledeletebridge;

/*
 * Copyright (c) 2005-2006 Rincon Research Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Rincon Research Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * ARCHED ROCK OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */


public class BFileDeleteMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 10;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 179;

    /** Create a new BFileDeleteMsg of size 10. */
    public BFileDeleteMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new BFileDeleteMsg of the given data_length. */
    public BFileDeleteMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BFileDeleteMsg with the given data_length
     * and base offset.
     */
    public BFileDeleteMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BFileDeleteMsg using the given byte array
     * as backing store.
     */
    public BFileDeleteMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BFileDeleteMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public BFileDeleteMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BFileDeleteMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public BFileDeleteMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BFileDeleteMsg embedded in the given message
     * at the given base offset.
     */
    public BFileDeleteMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BFileDeleteMsg embedded in the given message
     * at the given base offset and length.
     */
    public BFileDeleteMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <BFileDeleteMsg> \n";
      try {
        s += "  [short0=0x"+Long.toHexString(get_short0())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [short1=0x"+Long.toHexString(get_short1())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [fileName=";
        for (int i = 0; i < 8; i++) {
          s += "0x"+Long.toHexString(getElement_fileName(i) & 0xff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: short0
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'short0' is signed (false).
     */
    public static boolean isSigned_short0() {
        return false;
    }

    /**
     * Return whether the field 'short0' is an array (false).
     */
    public static boolean isArray_short0() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'short0'
     */
    public static int offset_short0() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'short0'
     */
    public static int offsetBits_short0() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'short0'
     */
    public short get_short0() {
        return (short)getUIntBEElement(offsetBits_short0(), 8);
    }

    /**
     * Set the value of the field 'short0'
     */
    public void set_short0(short value) {
        setUIntBEElement(offsetBits_short0(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'short0'
     */
    public static int size_short0() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'short0'
     */
    public static int sizeBits_short0() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: short1
    //   Field type: short, unsigned
    //   Offset (bits): 8
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'short1' is signed (false).
     */
    public static boolean isSigned_short1() {
        return false;
    }

    /**
     * Return whether the field 'short1' is an array (false).
     */
    public static boolean isArray_short1() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'short1'
     */
    public static int offset_short1() {
        return (8 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'short1'
     */
    public static int offsetBits_short1() {
        return 8;
    }

    /**
     * Return the value (as a short) of the field 'short1'
     */
    public short get_short1() {
        return (short)getUIntBEElement(offsetBits_short1(), 8);
    }

    /**
     * Set the value of the field 'short1'
     */
    public void set_short1(short value) {
        setUIntBEElement(offsetBits_short1(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'short1'
     */
    public static int size_short1() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'short1'
     */
    public static int sizeBits_short1() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: fileName
    //   Field type: short[], unsigned
    //   Offset (bits): 16
    //   Size of each element (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'fileName' is signed (false).
     */
    public static boolean isSigned_fileName() {
        return false;
    }

    /**
     * Return whether the field 'fileName' is an array (true).
     */
    public static boolean isArray_fileName() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'fileName'
     */
    public static int offset_fileName(int index1) {
        int offset = 16;
        if (index1 < 0 || index1 >= 8) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'fileName'
     */
    public static int offsetBits_fileName(int index1) {
        int offset = 16;
        if (index1 < 0 || index1 >= 8) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return offset;
    }

    /**
     * Return the entire array 'fileName' as a short[]
     */
    public short[] get_fileName() {
        short[] tmp = new short[8];
        for (int index0 = 0; index0 < numElements_fileName(0); index0++) {
            tmp[index0] = getElement_fileName(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'fileName' from the given short[]
     */
    public void set_fileName(short[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_fileName(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a short) of the array 'fileName'
     */
    public short getElement_fileName(int index1) {
        return (short)getUIntBEElement(offsetBits_fileName(index1), 8);
    }

    /**
     * Set an element of the array 'fileName'
     */
    public void setElement_fileName(int index1, short value) {
        setUIntBEElement(offsetBits_fileName(index1), 8, value);
    }

    /**
     * Return the total size, in bytes, of the array 'fileName'
     */
    public static int totalSize_fileName() {
        return (64 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'fileName'
     */
    public static int totalSizeBits_fileName() {
        return 64;
    }

    /**
     * Return the size, in bytes, of each element of the array 'fileName'
     */
    public static int elementSize_fileName() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'fileName'
     */
    public static int elementSizeBits_fileName() {
        return 8;
    }

    /**
     * Return the number of dimensions in the array 'fileName'
     */
    public static int numDimensions_fileName() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'fileName'
     */
    public static int numElements_fileName() {
        return 8;
    }

    /**
     * Return the number of elements in the array 'fileName'
     * for the given dimension.
     */
    public static int numElements_fileName(int dimension) {
      int array_dims[] = { 8,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /**
     * Fill in the array 'fileName' with a String
     */
    public void setString_fileName(String s) { 
         int len = s.length();
         int i;
         for (i = 0; i < len; i++) {
             setElement_fileName(i, (short)s.charAt(i));
         }
         setElement_fileName(i, (short)0); //null terminate
    }

    /**
     * Read the array 'fileName' as a String
     */
    public String getString_fileName() { 
         char carr[] = new char[Math.min(net.tinyos.message.Message.MAX_CONVERTED_STRING_LENGTH,8)];
         int i;
         for (i = 0; i < carr.length; i++) {
             if ((char)getElement_fileName(i) == (char)0) break;
             carr[i] = (char)getElement_fileName(i);
         }
         return new String(carr,0,i);
    }

}
