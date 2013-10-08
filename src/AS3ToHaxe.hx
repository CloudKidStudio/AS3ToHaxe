/*
 * Copyright (c) 2011, TouchMyPixel & contributors
 * Original author : Tarwin Stroh-Spijer <tarwin@touchmypixel.com>
 * Contributers: Tony Polinelli <tonyp@touchmypixel.com>,
 * 				Matt Karl <matt@cloudkid.com>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE TOUCH MY PIXEL & CONTRIBUTERS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE TOUCH MY PIXEL & CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

package;

import neko.Lib;
import sys.FileSystem;
import Sys;

using StringTools;
using AS3ToHaxe;

/**
 * Simple Program which iterates -from folder as3 documents, parses them to the -to folder as haxes files
 */
class AS3ToHaxe
{
	/** The valid command line parameters */
	public static var keys = ["-from", "-to", "-remove"];
	
	/** The path to export to */
	private var to:String;
	
	/** The source directory to look for AS3 files */
	private var from:String;
	
	/** If we should remove */
	private var remove:String;
	
	/** The system arguments */
	private var sysargs:Array<String>;
	
	/** The collection of  */
	private var files:Array<String>;
	
	/** Used for namespace */
	//public static var basePackage:String = "away3d";
	//private var nameSpaces:Map<String, ClassDefs>;
	//private var maxLoop:Int;
	
	/**
	*  Application entry point 
	*/
	static function main() 
	{
		new AS3ToHaxe();
	}
	
	/**
	*   Constructor for application 
	*/
	public function new()
	{
		//maxLoop = 1000;
		
		// Parse the commandline arguments
		if (parseArgs())
		{
			// make sure that the to directory exists
			if (!FileSystem.exists(to)) FileSystem.createDirectory(to);
			
			// delete old files
			if (remove == "true")
				removeDirectory(to);
			
			// Get all of the as files
			files = recurse(from);

			// to remember namespaces
			//nameSpaces = new Map<String, ClassDefs>();
			
			for (file in files)
			{
				// make sure we only work wtih AS fiels
				var ext = getExt(file);
				switch(ext)
				{
					case "as": 
						convert(file);
				}
			}
			
			// build namespace files
			//buildNameSpaces();
		}
	}
	
	/**
	*   Convert a single file from AS3 to Haxe
	*   @param The file path to convert
	*/
	private function convert(file:String):Void
	{		
		var fromFile = file;
		var toFile = to + "/" + file.substr(from.length + 1, file.lastIndexOf(".") - (from.length)) + "hx";
		
		var rF = "";
		var rC = "";
		
		var b = 0;
		
		// create the folder if it doesn''t exist
		var dir = toFile.substr(0, toFile.lastIndexOf("/"));
		createFolder(dir);
		
		var s = sys.io.File.getContent(fromFile);
		
		// spacse to tabs
		s = regReplace(s, "    ", "\t");
		
		// undent
		s = regReplace(s, "^\t", "");
		
		// some quick setup, finding what we''ve got
		var className = regMatch(s, "public class([ ]*)([A-Z][a-zA-Z0-9_]*)", 2)[1];

		// package
		s = regReplace(s, "package ([a-zA-Z\\.0-9-_]*)([ \n\r]*){", "package $1;\n", "gs");
		
		// remove last 
		s = regReplace(s, "\\}([\n\r\t ]*)\\}([\n\r\t ]*)$", "}", "gs");

		// extra indentation
		s = regReplace(s, "\n\t", "\n");
		
		// class
		s = regReplace(s, "public class", "class");
		
		// Replace final
		s = regReplace(s, "([ \\t\\n\\r]*)final (public|protected|private|function|static|class)", "$1@:final $2");

		// constructor
		s = regReplace(s, "function " + className, "function new");
		
		// Casts
		s = regReplace(s, "([^a-zA-Z0-9_.]+)Number\\(([^\\)]+)\\)", "$1Std.parseFloat($2)");
		s = regReplace(s, "([^a-zA-Z0-9_.]+)int\\((\\-?[0-9]*\\.[0-9]*+)\\)", "$1Std.int($2)");
		s = regReplace(s, "([^a-zA-Z0-9_.]+)int\\(([^\\)]+)\\)", "$1Std.parseInt($2)");
		s = regReplace(s, "([^a-zA-Z0-9_.]+)String\\(([^\\)]+)\\)", "$1Std.string($2)");
		s = regReplace(s, "([^a-zA-Z0-9_.\\[])([A-Z][a-zA-Z0-9_]*)\\(([^\\)]+)\\)", "$1cast($3, $2)");
		s = regReplace(s, "([^a-zA-Z0-9_.]+)([a-zA-Z_][a-zA-Z0-9_]*) +as +([A-Z][a-zA-Z0-9_]*)", "$1cast($2, $3)");
		s = regReplace(s, "([^a-zA-Z0-9_.]+)([a-zA-Z_][a-zA-Z0-9_]*)([ ]+)is([ ]+)([a-zA-Z_][a-zA-Z0-9_]*)", "$1Std.is($2,$5)");
		
		// simple typing
		s = regReplace(s, ":([ ]*)void", ":$1Void");
		s = regReplace(s, ":([ ]*)Boolean", ":$1Bool");
		s = regReplace(s, ":([ ]*)int", ":$1Int");
		s = regReplace(s, ":([ ]*)uint", ":$1UInt");
		s = regReplace(s, ":([ ]*)Number", ":$1Float");
		s = regReplace(s, ":([ ]*)\\*", ":$1Dynamic");
		
		s = regReplace(s, "<Number>", "<Float>");
		s = regReplace(s, "<int>", "<Int>");
		s = regReplace(s, "<uint>", "<UInt>");
		s = regReplace(s, "<Boolean>", "<Bool>");
		
		// vector definition replace with haxe typed arrays
		s = regReplace(s, "Vector([ ]*)\\.([ ]*)<([ ]*)([^>]*)([ ]*)>", "Array<$3$4$5>");
		
		// array
		s = regReplace(s, " Array([ ]*);", " Array<Dynamic>;");
		
		// remap protected -> private & internal -> private
		s = regReplace(s, "protected var", "private var");
		s = regReplace(s, "internal var", "private var");
		s = regReplace(s, "protected function", "private function");
		s = regReplace(s, "internal function", "private function");

		/* -----------------------------------------------------------*/
		// namespaces
		// find which namespaces are used in this class
		/*var r = new EReg("([^#])use([ ]+)namespace([ ]+)([a-zA-Z-]+)([ ]*);", "g");
		b = 0;
		while (true) {
			b++; if (b > maxLoop) { logLoopError("namespaces find", file); break; }
			if (r.match(s)) {
				nameSpaces.set(Std.string(r.matched(4)), new ClassDefs());
				s = r.replace(s, "//" + r.matched(0).replace("use", "#use") + "\nusing " + basePackage + ".namespace." + Std.string(r.matched(4)).fUpper() +  ";");
			}else {
				break;
			}
		}
		
		// collect all namespace definitions
		// replace them with private
		for (k in nameSpaces.keys()) {
			var n = nameSpaces.get(k);
			b = 0;
			while (true) {
				b++; if (b > maxLoop) { logLoopError("namespaces collect/replace var", file); break; }
				// vars
				var r = new EReg(n.name + "([ ]+)var([ ]+)", "g");
				s = r.replace(s, "private$1var$2");
				if (!r.match(s)) break;
			}
			b = 0;
			while (true) {
				b++; if (b > maxLoop) { logLoopError("namespaces collect/replace func", file); break; }
				// funcs
				var matched:Bool = false;
				var r = new EReg(n.name + "([ ]+)function([ ]+)", "g");
				if (r.match(s)) matched = true;
				s = r.replace(s, "private$1function$2");
				r = new EReg(n.name + "([ ]+)function([ ]+)get([ ]+)", "g");
				if (r.match(s)) matched = true;
				s = r.replace(s, "private$1function$2get$3");
				r = new EReg(n.name + "([ ]+)function([ ]+)set([ ]+)", "g");
				if (r.match(s)) matched = true;
				s = r.replace(s, "private$1function$2$3set");
				if (!matched) break;
			}
		}*/
		
		/* -----------------------------------------------------------*/
		// change const to inline statics
		s = regReplace(s, "([\n\t ]+)(public|private)([ ]*)const([ ]+)([a-zA-Z0-9_]+)([ ]*):", "$1$2$3static inline var$4$5$6:");
		s = regReplace(s, "([\n\t ]+)(public|private)([ ]*)(static)*([ ]+)const([ ]+)([a-zA-Z0-9_]+)([ ]*):", "$1$2$3$4$5inline var$6$7$8:");
		
		/* -----------------------------------------------------------*/
		// Error > flash.Error
		// if " Error (" then add "import flash.Error" to head
		var r = new EReg("([ ]+)new([ ]+)Error([ ]*)\\(", "");
		if (r.match(s))
			s = addImport(s, className, "flash.Error");
		
		
		/* -----------------------------------------------------------*/
		
		// replace the delete keyword
		s = regReplace(s, "([\n\t ]+)delete([ ]+)([^\\[]*+)\\[([^\\]]+)\\]", "$1Reflect.deleteField($3, $4)");
		s = regReplace(s, "([\n\t ]+)delete([ ]+)([^\\.]*+)\\.([^;]+)", "$1Reflect.deleteField($3, $4)");
		
		// Replace getTimer
		s = regReplace(s, "getTimer\\(\\)", "flash.Lib.getTimer()");
		
		/* -----------------------------------------------------------*/

		// create getters and setters		
		var matches = [];
		
		// Match all the 
		var r = new EReg("([\n\t ]+)([a-z]+)([ ]*)function([ ]+)get([ ]+)([a-zA-Z_][a-zA-Z0-9_]+)([ ]*)\\(([ ]*)\\)([ ]*):([ ]*)([A-Z][a-zA-Z0-9_]*)", "g");
		
		var originalStr = s;
		
		// Match all the getters
		while (r.match(s))
		{ 
			s = r.matchedRight();
			matches.push({ 
				get: true, 
				set: false, 
				type: r.matched(11), 
				getAccess: (r.matched(2) == "" ? "public" : r.matched(2)), 
				setAccess: null, 
				name: r.matched(6) 
			});
		}
		
		s = originalStr;
		
		var r = new EReg("([\n\t ]+)([a-z]+)([ ]*)function([ ]+)set([ ]+)([a-zA-Z_][a-zA-Z0-9_]*)([ ]*)\\(([ ]*)([a-zA-Z][a-zA-Z0-9_]*)([ ]*):([ ]*)([a-zA-Z][a-zA-Z0-9_]*)", "");
		
		// Match all the setters
		while (r.match(s))
		{ 
			var d = { 
				get: false, 
				set: true, 
				type: r.matched(12), 
				getAccess: null, 
				setAccess: null, 
				name: r.matched(6) 
			};
			var hasGetter = false;
			for(m in matches)
			{
				if (m.name == d.name)
				{
					d = m;
					d.set = true;
					hasGetter = true;
					break;
				}
			}
			
			d.setAccess = r.matched(2) == "" ? "public" : r.matched(2);
			s = r.matchedRight();
			
			if (!hasGetter) matches.push(d);
		}
		
		s = originalStr;
		
		for (m in matches)
		{
			// replace get
			if (m.get)
				s = regReplace(s, m.getAccess + "([ ]+)function([ ]+)get([ ]+)" + m.name, "private function get_" + m.name);
			
			// replace set
			if (m.set)
				s = regReplace(s, m.setAccess + "([ ]+)function([ ]+)set([ ]+)" + m.name +"([ ]*)\\(([^\\)]+)\\)([ ]*)[ :a-zA-Z0-9]*", "private function set_" + m.name + "($5)$6:" + m.type);
			
			var prop = (m.getAccess != null ? m.getAccess : m.setAccess) + " var " + m.name + "(" + (m.get ? 'get' : 'never') + ", " + (m.set ? 'set' : 'never') + "):" + m.type + ";";
			var func = (m.get ? "get" : "set") + "_" + m.name;
			s = regReplace(s, "private function " + func, prop + "\n \tprivate function " + func);
		}
		
		// Replace undefined with null
		s = regReplace(s, "undefined", "null", "g");
		
		// Replace strict operators, with lose ones
		s = regReplace(s, "===", "==", "g");
		s = regReplace(s, "!==", "!=", "g");
		
		// Replace Function types with Dynamic
		var r = new EReg(":([ ]*)Function", "");
		if (r.match(s))
			s = addImport(s, className, "flash.utils.Function");
		
		// Event meta tags
		// @:meta(Event(name="test",type="Foo"))
		s = regReplace(s, "\\[Event\\(([^\\)]*)\\)\\]", "@:meta(Event($1))");
		
		// dynamic properties
		s = regReplace(s, "\\.\\.\\.([a-zA-Z0-9]+)([ ]*)\\)", "$1:Array<Dynamic>$2)");
		
		/* -----------------------------------------------------------*/
		
		// Do for in loops first
		s = regReplace(s, "([ \t]*)for( *)\\(( *)(var )?([a-zA-Z_][a-zA-Z0-9_]*)( *: *[a-zA-Z_][a-zA-Z0-9_]+)?( *in *)([^\\) ]*)( *\\))", 
			"$1var fields = Reflect.fields($8);\n$1for$2($3$5$7fields$9", "g");
		
		// for loops that count
		// for (i=0; i < len; ++i) | for (var i : int = 0; i < len; ++i)
		s = regReplace(s, "for( *)\\(( *)(var )?([a-zA-Z_][a-zA-Z0-9_]*)( *: *[a-zA-Z_][a-zA-Z0-9_]+)? *= *([^;]*);[ a-zA-Z0-9_]*(<=|<|>|>=) *([a-zA-Z0-9_]*)[^\\)]*\\)", 
			"for$1($2$4 in $6...$8$2)", "g");
		
		// for loops that count without setting a variable int
		//for (var i : int; i < len; ++i)
		s = regReplace(s, "for( *)\\(( *)var ?([a-zA-Z_][a-zA-Z0-9_]*)(: *Int) *;[ a-zA-Z0-9_]*(<=|<|>|>=) *([a-zA-Z0-9_]*)[^\\)]*\\)", 
			"for$1($2$3 in 0...$6$2)", "g");
		
		// for each loops
		s = regReplace(s, "for each([ ]*)\\(([ ]*)(var )?([a-zA-Z_][a-zA-Z0-9_]*)( *: *[a-zA-Z_][a-zA-Z0-9_]*)?([ ]+)in([ ]+)([a-zA-Z_][a-zA-Z0-9_]*)([ ]*)\\)", 
			"for$1($2$4 in $8$2)", "g"); 
		
		/* -----------------------------------------------------------*/
		
		// Subsitutionts for qualified class name and definition
		s = regReplace(s, "getQualifiedClassName([ ]*)\\(", "Type.getClassName$1(", "g");
		s = regReplace(s, "getDefinitionByName([ ]*)\\(", "Type.getClass$1(", "g");

		var o = sys.io.File.write(toFile, true);
		o.writeString(s);
		o.close();
		
		// use for testing on a single file
		//Sys.exit(1);
	}
	
	/**
	*   Add an import to the stack of imports before the class definition 
	*   @param The full class string
	*   @param The class name to import (e.g. "flash.Error")
	*/
	public function addImport(s:String, className:String, classImport:String): String
	{
		return regReplace(s, "class([ ]*)(" + className + ")", "import "+classImport+";\n\nclass$1$2");
	}
	
	private function logLoopError(type:String, file:String)
	{
		trace("ERROR: " + type + " - " + file);
	}
	
	/**private function buildNameSpaces()
	{
		// build friend namespaces!
		//trace(nameSpaces);
	}*/
	
	public static function regReplace(str:String, reg:String, rep:String, ?regOpt:String = "g"):String
	{
		return new EReg(reg, regOpt).replace(str, rep);
	}
	
	/**
	*  Match all
	*  @param The string to match in 
	*  @param The regular expression to match
	*  @param The number of matches to fetch
	*  @param The regular expression options
	*/
	public static function regMatch(str:String, reg:String, ?numMatches:Int = 1, ?regOpt:String = "g"):Array<String>
	{
		var r = new EReg(reg, regOpt);
		var m = r.match(str);
		if (m) {
			var a = [];
			var i = 1;
			while (i <= numMatches) {
				a.push(r.matched(i));
				i++;
			}
			return a;
		}
		return [];
	}
	
	/**
	*   Create a new folder
	*   @param The folder path to create 
	*/
	private function createFolder(path:String):Void
	{
		var parts = path.split("/");
		var folder = "";
		for (part in parts)
		{
			if (folder == "") folder += part;
			else folder += "/" + part;
			if (!FileSystem.exists(folder)) FileSystem.createDirectory(folder);
		}
	}
	
	/**
	*  Parse tye command line arguments
	*  @return Boolean if we have the arguments we need
	*/
	private function parseArgs():Bool
	{
		// Parse args
		var args = Sys.args();
		for (i in 0...args.length)
			if (Lambda.has(keys, args[i]))
				Reflect.setField(this, args[i].substr(1), args[i + 1]);
			
		// Check to see if argument is missing
		if (to == null) { Lib.println("Missing argument '-to'"); return false; }
		if (from == null) { Lib.println("Missing argument '-from'"); return false; }
		
		return true;
	}
	
	/**
	*  Recursively go through directory and find all actionscript files
	*  @param The folder path
	*  @return A collection of file stirngs
	*/
	public function recurse(path:String):Array<String>
	{
		var dir = FileSystem.readDirectory(path);
		var result = new Array<String>();
		for (item in dir)
		{
			var s = path + "/" + item;
			if (FileSystem.isDirectory(s))
			{
				for (file in recurse(s))
					result.push(file);
			}
			else
			{
				if(Lambda.has(["as"], getExt(item)))
					result.push(s);
			}
		}
		return result;
	}
	
	/**
	*  Get a file's extension based on the path
	*  @param s The file path 
	*/
	public function getExt(s:String):String
	{
		return s.substr(s.lastIndexOf(".") + 1).toLowerCase();
	}
	
	/**
	*   Remove a directory
	*   @param d Directory path 
	*   @param p Parent item
	*/
	public function removeDirectory(d, p = null):Void
	{
		if (p == null) p = d;
		var dir = FileSystem.readDirectory(d);

		for (item in dir)
		{
			item = p + "/" + item;
			if (FileSystem.isDirectory(item)) {
				removeDirectory(item);
			}else{
				FileSystem.deleteFile(item);
			}
		}
		
		FileSystem.deleteDirectory(d);
	}
	
	/**
	*  Upper-case a string
	*  @param s The string to uppercase 
	*  @return The uppercase string
	*/
	public static function fUpper(s:String):String
	{
		return s.charAt(0).toUpperCase() + s.substr(1);
	}
}

class ClassDefs
{
	public var name:String;
	public var defs:Map<String, String>;
	public function new(){}
}