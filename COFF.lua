--[[
	References

	http://ivanlef0u.fr/repo/windoz/pe/CBM_1_2_2006_Goppit_PE_Format_Reverse_Engineer_View.pdf
http://msdn.microsoft.com/en-us/magazine/cc301808.aspx
--]]

package.path = package.path..";c:/repos/HeadsUp/core/?.lua"

local ffi = require "ffi"

require "BanateCore"
require "DataDescription"

--assuming machine is little endian
IMAGE_DOS_SIGNATURE     =            0x5A4D      -- MZ
IMAGE_OS2_SIGNATURE     =            0x454E      -- NE
IMAGE_OS2_SIGNATURE_LE  =            0x454C      -- LE
IMAGE_VXD_SIGNATURE     =            0x454C      -- LE
IMAGE_NT_SIGNATURE      =            0x00004550  -- PE00

IMAGE_NUMBEROF_DIRECTORY_ENTRIES    = 16

IMAGE_DIRECTORY_ENTRY_EXPORT          = 0   -- Export Directory
IMAGE_DIRECTORY_ENTRY_IMPORT          = 1   -- Import Directory
IMAGE_DIRECTORY_ENTRY_RESOURCE        = 2   -- Resource Directory
IMAGE_DIRECTORY_ENTRY_EXCEPTION       = 3   -- Exception Directory
IMAGE_DIRECTORY_ENTRY_SECURITY        = 4   -- Security Directory
IMAGE_DIRECTORY_ENTRY_BASERELOC       = 5   -- Base Relocation Table
IMAGE_DIRECTORY_ENTRY_DEBUG           = 6   -- Debug Directory
--      IMAGE_DIRECTORY_ENTRY_COPYRIGHT       7   -- (X86 usage)
IMAGE_DIRECTORY_ENTRY_ARCHITECTURE    = 7   -- Architecture Specific Data
IMAGE_DIRECTORY_ENTRY_GLOBALPTR       = 8   -- RVA of GP
IMAGE_DIRECTORY_ENTRY_TLS             = 9   -- TLS Directory
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG    = 10   -- Load Configuration Directory
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT   = 11   -- Bound Import Directory in headers
IMAGE_DIRECTORY_ENTRY_IAT            = 12   -- Import Address Table
IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT   = 13   -- Delay Load Import Descriptors
IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR = 14   -- COM Runtime descriptor

-- DOS .EXE header
PETypes = {

IMAGE_DOS_HEADER_Info = {
	name = "IMAGE_DOS_HEADER";
	fields = {
		{name = "e_magic", basetype="char", repeating=2},                     -- Magic number
		{name = "e_cblp", basetype="uint16_t"},                      -- Bytes on last page of file
		{name = "e_cp", basetype="uint16_t"},                        -- Pages in file
		{name = "e_crlc", basetype="uint16_t"},                      -- Relocations
		{name = "e_cparhdr", basetype="uint16_t"},                   -- Size of header in paragraphs
		{name = "e_minalloc", basetype="uint16_t"},                  -- Minimum extra paragraphs needed
		{name = "e_maxalloc", basetype="uint16_t"},                  -- Maximum extra paragraphs needed
		{name = "e_ss", basetype="uint16_t"},                        -- Initial (relative) SS value
		{name = "e_sp", basetype="uint16_t"},                        -- Initial SP value
		{name = "e_csum", basetype="uint16_t"},                      -- Checksum
		{name = "e_ip", basetype="uint16_t"},                        -- Initial IP value
		{name = "e_cs", basetype="uint16_t"},                        -- Initial (relative) CS value
		{name = "e_lfarlc", basetype="uint16_t"},                    -- File address of relocation table
		{name = "e_ovno", basetype="uint16_t"},                      -- Overlay number
		{name = "e_res", basetype="uint16_t", repeating=4},          -- Reserved s
		{name = "e_oemid", basetype="uint16_t"},                     -- OEM identifier (for e_oeminfo)
		{name = "e_oeminfo", basetype="uint16_t"},                   -- OEM information; e_oemid specific
		{name = "e_res2", basetype="uint16_t", repeating=10},        -- Reserved s
		{name = "e_lfanew", basetype="uint32_t"},                    -- File address of new exe header
  }
};

MAGIC2_Info = {
	name = "MAGIC2",
	fields = {
		{name = "Signature", basetype = "char", repeating = 2}
	}
};

MAGIC4_Info = {
	name = "MAGIC4",
	fields = {
		{name = "Signature", basetype = "char", repeating = 4}
	}
};


COFF_Info = {
	name = "COFF";
	fields = {
		{name = "Machine", basetype = "uint16_t"};
		{name = "NumberOfSections", basetype = "uint16_t"};
		{name = "TimeDateStamp", basetype = "uint32_t"};
		{name = "PointerToSymbolTable", basetype = "uint32_t"};
		{name = "NumberOfSymbols", basetype = "uint32_t"};
		{name = "SizeOfOptionalHeader", basetype = "uint16_t"};
		{name = "Characteristics", basetype = "uint16_t"};
	};

	enums = {
		MachineType = {
			{value = 0x0, name = "IMAGE_FILE_MACHINE_UNKNOWN", description = "any"},
			{value = 0x8664, name = "IMAGE_FILE_MACHINE_AMD64", description = "x64"},
			{value = 0x1c0, name = "IMAGE_FILE_MACHINE_ARM", description = "ARM little endian"},
			{value = 0x1c4, name = "IMAGE_FILE_MACHINE_ARMV7", description = "ARMv7 (or higher) Thumb mode only"},
			{value = 0x14c, name = "IMAGE_FILE_MACHINE_I386", description = "Intel 386 or later processors and compatible processors"},
			{value = 0x1c2, name = "IMAGE_FILE_MACHINE_THUMB", description = "ARM or Thumb (“interworking”)"},
		},

		Characteristics = {
			{value = 0x0001, name = "IMAGE_FILE_RELOCS_STRIPPED", description = "Image only, Windows CE, and Windows NT® and later. This indicates that the file does not contain base relocations and must therefore be loaded at its preferred base address. If the base address is not available, the loader reports an error. The default behavior of the linker is to strip base relocations from executable (EXE) files."},
			{value = 0x0002, name = "IMAGE_FILE_EXECUTABLE_IMAGE", description = "Image only. This indicates that the image file is valid and can be run. If this flag is not set, it indicates a linker error."},
		}
	}
};



PE32Header_Info = {
	name = "PE32Header",
	fields = {
		{name = "Magic", basetype="uint16_t"},	-- , default = 0x10b
		{name = "MajorLinkerVersion", basetype="uint8_t"},
		{name = "MinorLinkerVersion", basetype="uint8_t"},
		{name = "SizeOfCode", basetype="uint32_t"},
		{name = "SizeOfInitializedData", basetype="uint32_t"},
		{name = "SizeOfUninitializedData", basetype="uint32_t"},
		{name = "AddressOfEntryPoint", basetype="uint32_t"},
		{name = "BaseOfCode", basetype="uint32_t"},
		{name = "BaseOfData", basetype="uint32_t"},

		{name = "ImageBase", basetype="uint32_t"},
		{name = "SectionAlignment", basetype="uint32_t"},
		{name = "FileAlignment", basetype="uint32_t"},
		{name = "MajorOperatingSystemVersion", basetype="uint16_t"},
		{name = "MinorOperatingSystemVersion", basetype="uint16_t"},
		{name = "MajorImageVersion", basetype="uint16_t"},
		{name = "MinorImageVersion", basetype="uint16_t"},
		{name = "MajorSubsystemVersion", basetype="uint16_t"},
		{name = "MinorSubsystemVersion", basetype="uint16_t"},
		{name = "Win32VersionValue", basetype="uint32_t"},
		{name = "SizeOfImage", basetype="uint32_t"},
		{name = "SizeOfHeaders", basetype="uint32_t"},
		{name = "CheckSum", basetype="uint32_t"},
		{name = "Subsystem", basetype="uint16_t"},
		{name = "DllCharacteristics", basetype="uint16_t"},
		{name = "SizeOfStackReserve", basetype="uint32_t"},
		{name = "SizeOfStackCommit", basetype="uint32_t"},
		{name = "SizeOfHeapReserve", basetype="uint32_t"},
		{name = "SizeOfHeapCommit", basetype="uint32_t"},
		{name = "LoaderFlags", basetype="uint32_t"},
		{name = "NumberOfRvaAndSizes", basetype="uint32_t"},

		{name = "ExportTable", basetype="uint8_t", repeating=8},
		{name = "ImportTable", basetype="uint8_t", repeating=8},
		{name = "ResourceTable", basetype="uint8_t", repeating=8},
		{name = "ExceptionTable", basetype="uint8_t", repeating=8},
		{name = "CertificateTable", basetype="uint8_t", repeating=8},
		{name = "BaseRelocationTable", basetype="uint8_t", repeating=8},
		{name = "Debug", basetype="uint8_t", repeating=8},
		{name = "Architecture", basetype="uint8_t", repeating=8},
		{name = "GlobalPtr", basetype="uint8_t", repeating=8},
		{name = "TLSTable", basetype="uint8_t", repeating=8},
		{name = "LoadConfigTable", basetype="uint8_t", repeating=8},
		{name = "BoundImport", basetype="uint8_t", repeating=8},
		{name = "IAT", basetype="uint8_t", repeating=8},
		{name = "DelayImportDescriptor", basetype="uint8_t", repeating=8},
		{name = "CLRRuntimeHeader", basetype="uint8_t", repeating=8},
		{name = "Reserved", basetype="uint8_t", repeating=8},

	};

};

PE32PlusHeader_Info = {
	name = "PE32PlusHeader";
	fields = {
		{name = "Magic", basetype="uint16_t"},	-- , default = 0x20b
		{name = "MajorLinkerVersion", basetype="uint8_t"},
		{name = "MinorLinkerVersion", basetype="uint8_t"},
		{name = "SizeOfCode", basetype="uint32_t"},
		{name = "SizeOfInitializedData", basetype="uint32_t"},
		{name = "SizeOfUninitializedData", basetype="uint32_t"},
		{name = "AddressOfEntryPoint", basetype="uint32_t"},
		{name = "BaseOfCode", basetype="uint32_t"},

		{name = "ImageBase", basetype="uint64_t"},
		{name = "SectionAlignment", basetype="uint32_t"},
		{name = "FileAlignment", basetype="uint32_t"},
		{name = "MajorOperatingSystemVersion", basetype="uint16_t"},
		{name = "MinorOperatingSystemVersion", basetype="uint16_t"},
		{name = "MajorImageVersion", basetype="uint16_t"},
		{name = "MinorImageVersion", basetype="uint16_t"},
		{name = "MajorSubsystemVersion", basetype="uint16_t"},
		{name = "MinorSubsystemVersion", basetype="uint16_t"},
		{name = "Win32VersionValue", basetype="uint32_t"},
		{name = "SizeOfImage", basetype="uint32_t"},
		{name = "SizeOfHeaders", basetype="uint32_t"},
		{name = "CheckSum", basetype="uint32_t"},
		{name = "Subsystem", basetype="uint16_t"},
		{name = "DllCharacteristics", basetype="uint16_t"},
		{name = "SizeOfStackReserve", basetype="uint64_t"},
		{name = "SizeOfStackCommit", basetype="uint64_t"},
		{name = "SizeOfHeapReserve", basetype="uint64_t"},
		{name = "SizeOfHeapCommit", basetype="uint64_t"},
		{name = "LoaderFlags", basetype="uint32_t"},
		{name = "NumberOfRvaAndSizes", basetype="uint32_t"},

		{name = "ExportTable", basetype="uint8_t", repeating=8},
		{name = "ImportTable", basetype="uint8_t", repeating=8},
		{name = "ResourceTable", basetype="uint8_t", repeating=8},
		{name = "ExceptionTable", basetype="uint8_t", repeating=8},
		{name = "CertificateTable", basetype="uint8_t", repeating=8},
		{name = "BaseRelocationTable", basetype="uint8_t", repeating=8},
		{name = "Debug", basetype="uint8_t", repeating=8},
		{name = "Architecture", basetype="uint8_t", repeating=8},
		{name = "GlobalPtr", basetype="uint8_t", repeating=8},
		{name = "TLSTable", basetype="uint8_t", repeating=8},
		{name = "LoadConfigTable", basetype="uint8_t", repeating=8},
		{name = "BoundImport", basetype="uint8_t", repeating=8},
		{name = "IAT", basetype="uint8_t", repeating=8},
		{name = "DelayImportDescriptor", basetype="uint8_t", repeating=8},
		{name = "CLRRuntimeHeader", basetype="uint8_t", repeating=8},
		{name = "Reserved", basetype="uint8_t", repeating=8},

	};

};

IMAGE_DATA_DIRECTORY_Info = {
	name = "IMAGE_DATA_DIRECTORY",
	fields = {
		{name = "VirtualAddress", basetype="uint32_t"},
		{name = "Size", basetype="uint32_t"},
	}
};

IMAGE_SECTION_HEADER_Info = {
	name = "IMAGE_SECTION_HEADER",
	fields = {
		{name = "Name", basetype="char", repeating=8},	-- has terminating 0 sometimes, otherwise, 8 bytes
		{name = "VirtualSize", basetype="uint32_t"},
		{name = "VirtualAddress", basetype="uint32_t"},
		{name = "SizeOfRawData", basetype="uint32_t"},
		{name = "PointerToRawData", basetype="uint32_t"},
		{name = "PointerToRelocations", basetype="uint32_t"},
		{name = "PointerToLinenumbers", basetype="uint32_t"},
		{name = "NumberOfRelocations", basetype="uint16_t"},
		{name = "NumberOfLinenumbers", basetype="uint16_t"},
		{name = "Characteristics", basetype="uint32_t"},
	}
};



IMAGE_EXPORT_DIRECTORY_Info = {
	name = "IMAGE_EXPORT_DIRECTORY",
	fields = {
		{name = "Characteristics", basetype = "uint32_t"};
		{name = "TimeDateStamp", basetype = "uint32_t"};
		{name = "MajorVersion", basetype = "uint16_t"};
		{name = "MinorVersion", basetype = "uint16_t"};
		{name = "Name", basetype = "uint32_t"};
		{name = "Base", basetype = "uint32_t"};
		{name = "NumberOfFunctions", basetype = "uint32_t"};
		{name = "NumberOfNames", basetype = "uint32_t"};
		{name = "AddressOfFunctions", basetype = "uint32_t"};
		{name = "AddressOfNames", basetype = "uint32_t"};
		{name = "AddressOfNameOrdinals", basetype = "uint32_t"};
	};
};


IMAGE_IMPORT_DESCRIPTOR_Info = {
	name = "IMAGE_IMPORT_DESCRIPTOR",
	fields = {
		{name = "OriginalFirstThunk", basetype = "uint32_t"};
		{name = "TimeDateStamp", basetype = "int32_t"};
		{name = "ForwarderChain", basetype="int32_t"};
		{name = "Name", basetype="uint32_t"};
		{name = "FirstThunk", basetype = "uint32_t"};
	};
};

IMAGE_IMPORT_BY_NAME_Info = {
    name = "IMAGE_IMPORT_BY_NAME";
	fields = {
		{name = "Hint", basetype="uint16_t"};
		{name = "Name", basetype="char", subtype="string", repeating=1};
	}
};

--[[
IMAGE_THUNK_DATA64_Info =  {
    union {
        ULONGLONG ForwarderString;  // PBYTE
        ULONGLONG Function;         // PDWORD
        ULONGLONG Ordinal;
        ULONGLONG AddressOfData;    // PIMAGE_IMPORT_BY_NAME
    } u1;
};
--]]

IMAGE_THUNK_DATA_Info = {
	name = "IMAGE_THUNK_DATA";
	fields = {
		{name="Data", basetype="uint32_t"}
	};
--[[
    union {
        DWORD ForwarderString;      -- PBYTE
        DWORD Function;             -- PDWORD
        DWORD Ordinal;
        DWORD AddressOfData;        -- PIMAGE_IMPORT_BY_NAME
    } u1;
--]]
} ;


IMAGE_BOUND_IMPORT_DESCRIPTOR_Info = {
	name = "IMAGE_BOUND_IMPORT_DESCRIPTOR",
	fields = {
		{name = "TimeDateStamp", basetype = "int32_t"};
		{name = "OffsetModuleName", basetype="int16_t"};
		{name = "NumberOfModuleForwarderRefs", basetype="uint16_t"};
		-- Array of zero or more IMAGE_BOUND_FORWARDER_REF follows
	};
};

IMAGE_BOUND_FORWARDER_REF_Info = {
	name = "IMAGE_BOUND_FORWARDER_REF",
	fields = {
		{name = "TimeDateStamp", basetype = "uint32_t"};
		{name = "OffsetModuleName", basetype="int16_t"};
		{name = "Reserved", basetype="uint16_t"};
	};
};

ImportHeader_Info = {
	name = "ImportHeader",
	fields = {
		{name = "Sig1", basetype="uint16_t"},
		{name = "Sig2", basetype="uint16_t"},
		{name = "Version", basetype="uint16_t"},
		{name = "Machine", basetype="uint16_t"},
		{name = "TimeDateStamp", basetype="uint32_t"},
		{name = "SizeOfData", basetype="uint32_t"},
		{name = "OrdinalHint", basetype="uint16_t"},
		{name = "Type", basetype="uint16_t", subtype="bit", repeating=2},
		{name = "NameType", basetype="uint16_t", subtype="bit", repeating=3},
		{name = "Reserved", basetype="uint16_t", subtype="bit", repeating=11},
	}
};

}


function IsPEFormatImageFile(header)
local sig = header:get_Signature()
print(sig[0], sig[1], sig[2], sig[3])
	return sig[0] == string.byte('P') and
		sig[1] == string.byte('E') and
		sig[2] == 0 and
		sig[3] == 0

end

function IsPe32Header(header)
local sig = header:get_Signature()
	return sig[0] == 0x0b and sig[1] == 0x01
end

function IsPe32PlusHeader(header)
local sig = header:get_Signature()
	return sig[0] == 0x0b and sig[1] == 0x02
end


function GetSectionPtr(name, browser)
	local section = browser.Sections[name]

	if not section then return nil end

	return browser.Buffer + section:get_PointerToRawData()
end

function GetPtrFromRVA(rva, browser)

	local delta;
	local pSectionHdr = GetEnclosingSectionHeader( rva, browser );

	if ( not pSectionHdr ) then
		return nil;
	end

	delta = (pSectionHdr:get_VirtualAddress() - pSectionHdr:get_PointerToRawData());
	return ( browser.Buffer + rva - delta );
end

--
-- Given an RVA, look up the section header that encloses it and return a
-- pointer to its IMAGE_SECTION_HEADER
--
function GetEnclosingSectionHeader(rva, browser)
    for secname, section in pairs(browser.Sections) do
        -- Is the RVA within this section?
        if (rva >= section:get_VirtualAddress()) and
             (rva < (section:get_VirtualAddress() + section:get_VirtualSize())) then
            return section;
		end
    end

    return nil;
end

function buildDirectories(peheader)
	local dirs = {}

	local tbl = IMAGE_DATA_DIRECTORY(peheader:get_ExportTable())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_EXPORT
	dirs.Export = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_ImportTable())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_IMPORT
	dirs.Import = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_ResourceTable())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_RESOURCE
	dirs.Resource = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_ExceptionTable())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_EXCEPTION
	dirs.Exception = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_CertificateTable())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_SECURITY
	dirs.Security = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_BaseRelocationTable())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_BASERELOC
	dirs.BaseRelocation = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_Debug())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_DEBUG
	dirs.Debug = tbl


	tbl = IMAGE_DATA_DIRECTORY(peheader:get_Architecture())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_ARCHITECTURE
	dirs.Architecture = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_GlobalPtr())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_GLOBALPTR
	dirs.GlobalPtr = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_TLSTable())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_TLS
	dirs.TLS = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_LoadConfigTable())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG
	dirs.Config = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_BoundImport())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT
	dirs.BoundImport = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_IAT())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_IAT
	dirs.IAT = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_DelayImportDescriptor())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT
	dirs.DelayImport = tbl

	tbl = IMAGE_DATA_DIRECTORY(peheader:get_CLRRuntimeHeader())
	tbl.DIRID = IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR
	dirs.COM = tbl

--	tbl = IMAGE_DATA_DIRECTORY(peheader:get_Reserved())
--	tbl.DIRID = -1
--	table.insert(dirs, tbl)


	return dirs;
end

local function stringFromBuff(buff, size)
	local truelen = size
	for i=size-1,0,-1 do
		if buff[i] == 0 then
		    truelen = truelen - 1
		end
	end
	return ffi.string(buff, truelen)
end

function buildSectionHeaders(pefile)
	local sections = {}
	local nsections = pefile.FileHeader:get_NumberOfSections()

	local offset = pefile.PEHeader.Offset + pefile.PEHeader.ClassSize
	for i=1,nsections do
		local sec = IMAGE_SECTION_HEADER(pefile.PEHeader.Buffer, pefile.PEHeader.BufferSize, offset)
		local nameptr, len = sec:get_Name()
		local name = stringFromBuff(nameptr, len)
		sec.Name = name
		sections[name] = sec

		offset = offset + sec.ClassSize
	end

	return sections
end

function CreatePEClasses()
	for k,v in pairs(PETypes) do
--print(k)
		local c1 = CreateBufferClass(v)
--print(c1)
		local f = loadstring(c1)
		f()
	end
end

CreatePEClasses()
