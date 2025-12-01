using RaylibBeef;
using System;

namespace RaylibAsepriteBeef;

public static class RaylibAseprite
{
	const int32 CUTE_ASEPRITE_MAX_LAYERS = 64;
 	const int32 CUTE_ASEPRITE_MAX_SLICES = 128;
 	const int32 CUTE_ASEPRITE_MAX_PALETTE_ENTRIES = 1024;
	const int32 CUTE_ASEPRITE_MAX_TAGS = 256;

	[CRepr]
	struct ase_color_t
	{
		uint8 r, g, b, a;
	};

	[CRepr]
	struct ase_fixed_t
	{
		uint16 a;
		uint16 b;
	};

	[CRepr]
	struct ase_udata_t
	{
		int32 has_color;
		ase_color_t color;
		int32 has_text;
		char8* text;
	};

	[CRepr]
	enum ase_layer_flags_t
	{
		ASE_LAYER_FLAGS_VISIBLE            = 0x01,
		ASE_LAYER_FLAGS_EDITABLE           = 0x02,
		ASE_LAYER_FLAGS_LOCK_MOVEMENT      = 0x04,
		ASE_LAYER_FLAGS_BACKGROUND         = 0x08,
		ASE_LAYER_FLAGS_PREFER_LINKED_CELS = 0x10,
		ASE_LAYER_FLAGS_COLLAPSED          = 0x20,
		ASE_LAYER_FLAGS_REFERENCE          = 0x40,
	};

	[CRepr]
	enum ase_layer_type_t
	{
		ASE_LAYER_TYPE_NORMAL,
		ASE_LAYER_TYPE_GROUP,
	};

	[CRepr]
	struct ase_layer_t
	{
		ase_layer_flags_t flags;
		ase_layer_type_t type;
		char8* name;
		ase_layer_t* parent;
		float opacity;
		ase_udata_t udata;
	};

	[CRepr]
	struct ase_cel_extra_chunk_t
	{
		int32 precise_bounds_are_set;
		ase_fixed_t precise_x;
		ase_fixed_t precise_y;
		ase_fixed_t w, h;
	};

	[CRepr]
	struct ase_cel_t
	{
		ase_layer_t* layer;
		void* pixels;
		int32 w, h;
		int32 x, y;
		float opacity;
		int32 is_linked;
		uint16 linked_frame_index;
		int32 has_extra;
		ase_cel_extra_chunk_t extra;
		ase_udata_t udata;
	};

	[CRepr]
	struct ase_frame_t
	{
		ase_t* ase;
		int32 duration_milliseconds;
		ase_color_t* pixels;
		int32 cel_count;
		ase_cel_t[CUTE_ASEPRITE_MAX_LAYERS] cels;
	};

	[CRepr]
	enum ase_animation_direction_t
	{
		ASE_ANIMATION_DIRECTION_FORWARDS,
		ASE_ANIMATION_DIRECTION_BACKWORDS,
		ASE_ANIMATION_DIRECTION_PINGPONG,
	};

	[CRepr]
	public struct ase_tag_t
	{
		public int32 from_frame;
		public int32 to_frame;
		ase_animation_direction_t loop_animation_direction;
		public int32 rep; //repeat
		uint8 r, g, b;
		char8* name;
		ase_udata_t udata;
	};

	[CRepr]
	struct ase_slice_t
	{
		char8* name;
		int32 frame_number;
		int32 origin_x;
		int32 origin_y;
		int32 w, h;

		int32 has_center_as_9_slice;
		int32 center_x;
		int32 center_y;
		int32 center_w;
		int32 center_h;

		int32 has_pivot;
		int32 pivot_x;
		int32 pivot_y;

		ase_udata_t udata;
	};

	[CRepr]
	struct ase_palette_entry_t
	{
		ase_color_t color;
		char8* color_name;
	};

	[CRepr]
	public struct ase_palette_t
	{
		public int32 entry_count;
		ase_palette_entry_t[CUTE_ASEPRITE_MAX_PALETTE_ENTRIES] entries;
	};

	[CRepr]
	enum ase_color_profile_type_t
	{
		ASE_COLOR_PROFILE_TYPE_NONE,
		ASE_COLOR_PROFILE_TYPE_SRGB,
		ASE_COLOR_PROFILE_TYPE_EMBEDDED_ICC,
	};

	[CRepr]
	struct ase_color_profile_t
	{
		ase_color_profile_type_t type;
		int32 use_fixed_gamma;
		ase_fixed_t gamma;
		uint32 icc_profile_data_length;
		void* icc_profile_data;
	};

	[CRepr]
	public enum ase_mode_t
	{
		ASE_MODE_RGBA,
		ASE_MODE_GRAYSCALE,
		ASE_MODE_INDEXED
	};

	[CRepr]
	public struct ase_t
	{
		public ase_mode_t mode;
		int32 w, h;
		public int32 transparent_palette_entry_index;
		int32 number_of_colors;
		int32 pixel_w;
		int32 pixel_h;
		int32 grid_x;
		int32 grid_y;
		int32 grid_w;
		int32 grid_h;
		int32 has_color_profile;
		ase_color_profile_t color_profile;
		public ase_palette_t palette;

		int32 layer_count;
		ase_layer_t[CUTE_ASEPRITE_MAX_LAYERS] layers;

		int32 frame_count;
		ase_frame_t* frames;

		public int32 tag_count;
		public ase_tag_t[CUTE_ASEPRITE_MAX_TAGS] tags;

		int32 slice_count;
		ase_slice_t[CUTE_ASEPRITE_MAX_SLICES] slice;

		void* mem_ctx;
	};

	//-----

	public static AsepriteTag GenDefaultTag(Aseprite ase)
	{
		var tag = GenAsepriteTagDefault();
		tag.aseprite = ase;
		tag.color = .(255,255,255,255);
		tag.currentFrame = 0;
		tag.direction = 0;
		tag.loop = true;
		tag.name = "default";
		tag.speed = 1f;
		tag.paused = false;
		tag.timer = 1f;

		ase.ase.tag_count = 1;
		ase_tag_t* t = &ase.ase.tags[0];
		t.from_frame = 0;
		t.to_frame = (int32)GetAsepriteFrameCount(ase)-1;
		t.rep = 1;
		tag.tag = t;

		return tag;
	}

	public static int GetAsepriteFrameCount(Aseprite a)
	{
		return a.ase.[Friend]frame_count;
	}

	public static void SetTag(Aseprite a, AsepriteTag* t)
	{
		a.ase.tags[0] = *t.tag;
	}

	[CRepr]
	public struct Aseprite {
	    public ase_t* ase;         // Pointer to the cute_aseprite data.
	};

	[CRepr]
	public struct AsepriteTag {
	    public char8* name;         // The name of the tag.
	    public int32 currentFrame;   // The frame that the tag is currently on
	    public float timer;        // The countdown timer in seconds
	    public int32 direction;      // Whether we are moving forwards, or backwards through the frames
	    public float speed;        // The animation speed factor (1 is normal speed, 2 is double speed)
	    public Color color;        // The color provided for the tag
	    public bool loop;          // Whether to continue to play the animation when the animation finishes
	    public bool paused;        // Set to true to not progression of the animation
	    public Aseprite aseprite;  // The loaded Aseprite file
	    public ase_tag_t* tag;     // The active tag to act upon
	};

	[CRepr]
	public struct AsepriteSlice {
	    public char8* name;         // The name of the slice.
	    public Rectangle bounds;   // The rectangle outer bounds for the slice.
	};

	// Aseprite functions

	// Load an .aseprite file
	[CLink]
	public static extern Aseprite LoadAseprite(char8* fileName);                        

	// Load an aseprite file from memory
	[CLink]
	public static extern Aseprite LoadAsepriteFromMemory(uint8* fileData, int32 size);  

	// Check if the given Aseprite was loaded successfully
	[CLink]
	public static extern bool IsAsepriteValid(Aseprite aseprite);                           

	// Unloads the aseprite file
	[CLink]
	public static extern void UnloadAseprite(Aseprite aseprite);                             

	// Display all information associated with the aseprite
	[CLink]
	public static extern void TraceAseprite(Aseprite aseprite);                              

	// Retrieve the raylib texture associated with the aseprite
	[CLink]
	public static extern Texture GetAsepriteTexture(Aseprite aseprite);                      

	// Get the width of the sprite
	[CLink]
	public static extern int32 GetAsepriteWidth(Aseprite aseprite);                            

	// Get the height of the sprite
	[CLink]
	public static extern int32 GetAsepriteHeight(Aseprite aseprite);                           

	[CLink]
	public static extern void DrawAseprite(Aseprite aseprite, int32 frame, int32 posX, int32 posY, Color tint);

	[CLink]
	public static extern void DrawAsepriteFlipped(Aseprite aseprite, int32 frame, int32 posX, int32 posY, bool horizontalFlip, bool verticalFlip, Color tint);

	[CLink]
	public static extern void DrawAsepriteV(Aseprite aseprite, int32 frame, Vector2 position, Color tint);

	[CLink]
	public static extern void DrawAsepriteVFlipped(Aseprite aseprite, int32 frame, Vector2 position, bool horizontalFlip, bool verticalFlip, Color tint);

	[CLink]
	public static extern void DrawAsepriteExFlipped(Aseprite aseprite, int32 frame, Vector2 position, float rotation, float scale, bool horizontalFlip, bool verticalFlip, Color tint);

	[CLink]
	public static extern void DrawAsepritePro(Aseprite aseprite, int32 frame, Rectangle dest, Vector2 origin, float rotation, Color tint);

	[CLink]
	public static extern void DrawAsepriteProFlipped(Aseprite aseprite, int32 frame, Rectangle dest, Vector2 origin, float rotation, bool horizontalFlip, bool verticalFlip, Color tint);

	

	// Aseprite Tag functions
	
	// Load an Aseprite tag animation sequence
	[CLink]
	public static extern AsepriteTag LoadAsepriteTag(Aseprite aseprite, char8* name);   

	// Load an Aseprite tag animation sequence from its index
	[CLink]
	public static extern AsepriteTag LoadAsepriteTagFromIndex(Aseprite aseprite, int32 index); 

	// Get the total amount of available tags
	[CLink]
	public static extern int32 GetAsepriteTagCount(Aseprite aseprite);                         

	// Check if the given Aseprite tag was loaded successfully
	[CLink]
	public static extern bool IsAsepriteTagValid(AsepriteTag tag);                           

	// Update the tag animation frame
	[CLink]
	public static extern void UpdateAsepriteTag(AsepriteTag* tag);                           

	// Generate an empty Tag with sane defaults
	[CLink]
	public static extern AsepriteTag GenAsepriteTagDefault();                                

	[CLink]
	public static extern void DrawAsepriteTag(AsepriteTag tag, int32 posX, int32 posY, Color tint);

	[CLink]
	public static extern void DrawAsepriteTagFlipped(AsepriteTag tag, int32 posX, int32 posY, bool horizontalFlip, bool verticalFlip, Color tint);

	[CLink]
	public static extern void DrawAsepriteTagV(AsepriteTag tag, Vector2 position, Color tint);

	[CLink]
	public static extern void DrawAsepriteTagVFlipped(AsepriteTag tag, Vector2 position, bool horizontalFlip, bool verticalFlip, Color tint);

	[CLink]
	public static extern void DrawAsepriteTagEx(AsepriteTag tag, Vector2 position, float rotation, float scale, Color tint);

	[CLink]
	public static extern void DrawAsepriteTagExFlipped(AsepriteTag tag, Vector2 position, float rotation, float scale, bool horizontalFlip, bool verticalFlip, Color tint);

	[CLink]
	public static extern void DrawAsepriteTagPro(AsepriteTag tag, Rectangle dest, Vector2 origin, float rotation, Color tint);

	[CLink]
	public static extern void DrawAsepriteTagProFlipped(AsepriteTag tag, Rectangle dest, Vector2 origin, float rotation, bool horizontalFlip, bool verticalFlip, Color tint);

	// Sets which frame the tag is currently displaying.
	[CLink]
	public static extern void SetAsepriteTagFrame(AsepriteTag* tag, int32 frameNumber);                           

	[CLink]
	public static extern int32 GetAsepriteTagFrame(AsepriteTag tag);

	// Aseprite Slice functions
	// Load a slice from an Aseprite based on its name.
	[CLink]
	public static extern AsepriteSlice LoadAsepriteSlice(Aseprite aseprite, char8* name);   

	// Load a slice from an Aseprite based on its index.
	[CLink]
	public static extern AsepriteSlice LoadAsperiteSliceFromIndex(Aseprite aseprite, int32 index); 

	// Get the amount of slices that are defined in the Aseprite.
	[CLink]
	public static extern int32 GetAsepriteSliceCount(Aseprite aseprite);                       

	// Return whether or not the given slice was found.
	[CLink]
	public static extern bool IsAsepriteSliceValid(AsepriteSlice slice);                     

	// Generate empty Aseprite slice data.
	[CLink]
	public static extern AsepriteSlice GenAsepriteSliceDefault();                            

}