package pako;

import pako.Pako;
import js.html.Uint8Array;
import js.html.ArrayBuffer;
import haxe.extern.EitherType;

typedef InflateOptions = {
	@:optional var windowBits:Int;
	@:optional var chunkSize:Int;
	@:optional var raw:Bool;
	@:optional var to:String;
	@:optional var dictionary:Dictionary;
}

/**
	Generic JS-style wrapper for zlib calls.
	If you don't need streaming behavior - use more simple functions: `Pako.inflate` and `Pako.inflateRaw`.
**/
@:native('pako.Inflate')
extern class Inflate {
	/**
		Creates new inflator instance with specified params.
		Throws exception on bad params.

		Supported options: `windowBits`, `dictionary`
		@see http://zlib.net/manual.html#Advanced

		Additional options, for internal needs:
			`chunkSize` - size of generated data chunks (16K by default)
			`raw` - do raw inflate
			`to` - if equal to 'string', then result will be converted from utf8 to utf16 (javascript) string. When string output requested, chunk length can differ from chunkSize, depending on content.

		By default, when no options set, autodetect deflate/gzip data format via wrapper header.
	**/
	public function new(?options:InflateOptions);

	/** Error code after inflate finished. 0 (`Pako.Z_OK`) on success. Should be checked if broken data possible. */
	public var err(default, null):Int;
	/** Error message, if `Inflate.err` != 0 */
	public var msg(default, null):String;
	/**
		Uncompressed result, generated by default `Inflate#onData` and `Inflate#onEnd` handlers.
		Filled after you push last chunk (call `Inflate#push` with `Pako.Z_FINISH` / `true` param)
		or if you push a chunk with explicit flush (call `Inflate#push` with `Pako.Z_SYNC_FLUSH` param).
	**/
	@:overload(var result:Array<Int>)
	@:overload(var result:Uint8Array)
	public var result:String;

	/**
		By default, stores data blocks in `chunks[]` property and glue those in `onEnd`.
		Override this handler, if you need another behavior.

		@param chunk - output data. Type of array depends on js engine support. When string output requested, each chunk will be string.
	**/
	@:overload(function(chunk:Uint8Array):Void{})
	@:overload(function(chunk:Array<Int>):Void{})
	public dynamic function onData(chunk:String):Void;

	/**
		Called either after you tell inflate that the input stream is complete (`Pako.Z_FINISH`)
		or should be flushed (`Pako.Z_SYNC_FLUSH`) or if an error happened.
		By default - join collected chunks, free memory and fill results / err properties.

		@param status - inflate status. 0 (Z_OK) on success, other if not.
	**/
	public function onEnd(status:Int):Void;

	/**
		Sends input data to inflate pipe, generating `Inflate.onData` calls with new output chunks.
		Returns true on success.
		The last data block must have mode `Pako.Z_FINISH` (or `true`). That will flush internal pending buffers and call `Inflate#onEnd`.
		For interim explicit flushes (without ending the stream) you can use mode `Pako.Z_SYNC_FLUSH`, keeping the decompression context.

		On fail call `Inflate#onEnd` with error code and return `false`.

		We strongly recommend to use `Uint8Array` on input for best speed (output format is detected automatically).

		For regular Array-s make sure all elements are [0..255].

		@param data - input data
		@param mode - 0..6 for corresponding `Pako.Z_NO_FLUSH`..`Pako.Z_TREE` modes. See constants.
						Skipped or false means `Pako.Z_NO_FLUSH`, `true` means `Pako.Z_FINISH`.
	**/
	@:overload(function(data:Uint8Array, mode:EitherType<Int,Bool>):Bool{})
	@:overload(function(data:Array<Int>, mode:EitherType<Int,Bool>):Bool{})
	@:overload(function(data:ArrayBuffer, mode:EitherType<Int,Bool>):Bool{})
	public function push(data:String, mode:EitherType<Int,Bool>):Bool;
}