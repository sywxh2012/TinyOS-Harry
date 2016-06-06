/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'ReactWatchMsg'
 * message type.
 */

package simx.mig;

public class ReactWatchMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 3;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 201;

    /** Create a new ReactWatchMsg of size 3. */
    public ReactWatchMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new ReactWatchMsg of the given data_length. */
    public ReactWatchMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ReactWatchMsg with the given data_length
     * and base offset.
     */
    public ReactWatchMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ReactWatchMsg using the given byte array
     * as backing store.
     */
    public ReactWatchMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ReactWatchMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public ReactWatchMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ReactWatchMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public ReactWatchMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ReactWatchMsg embedded in the given message
     * at the given base offset.
     */
    public ReactWatchMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ReactWatchMsg embedded in the given message
     * at the given base offset and length.
     */
    public ReactWatchMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <ReactWatchMsg> \n";
      try {
        s += "  [var_id=0x"+Long.toHexString(get_var_id())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [ve_start_byte=0x"+Long.toHexString(get_ve_start_byte())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: var_id
    //   Field type: int, signed
    //   Offset (bits): 0
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'var_id' is signed (true).
     */
    public static boolean isSigned_var_id() {
        return true;
    }

    /**
     * Return whether the field 'var_id' is an array (false).
     */
    public static boolean isArray_var_id() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'var_id'
     */
    public static int offset_var_id() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'var_id'
     */
    public static int offsetBits_var_id() {
        return 0;
    }

    /**
     * Return the value (as a int) of the field 'var_id'
     */
    public int get_var_id() {
        return (int)getUIntBEElement(offsetBits_var_id(), 16);
    }

    /**
     * Set the value of the field 'var_id'
     */
    public void set_var_id(int value) {
        setUIntBEElement(offsetBits_var_id(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'var_id'
     */
    public static int size_var_id() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'var_id'
     */
    public static int sizeBits_var_id() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: ve_start_byte
    //   Field type: byte, signed
    //   Offset (bits): 16
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 've_start_byte' is signed (true).
     */
    public static boolean isSigned_ve_start_byte() {
        return true;
    }

    /**
     * Return whether the field 've_start_byte' is an array (false).
     */
    public static boolean isArray_ve_start_byte() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 've_start_byte'
     */
    public static int offset_ve_start_byte() {
        return (16 / 8);
    }

    /**
     * Return the offset (in bits) of the field 've_start_byte'
     */
    public static int offsetBits_ve_start_byte() {
        return 16;
    }

    /**
     * Return the value (as a byte) of the field 've_start_byte'
     */
    public byte get_ve_start_byte() {
        return (byte)getSIntBEElement(offsetBits_ve_start_byte(), 8);
    }

    /**
     * Set the value of the field 've_start_byte'
     */
    public void set_ve_start_byte(byte value) {
        setSIntBEElement(offsetBits_ve_start_byte(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 've_start_byte'
     */
    public static int size_ve_start_byte() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 've_start_byte'
     */
    public static int sizeBits_ve_start_byte() {
        return 8;
    }

}
