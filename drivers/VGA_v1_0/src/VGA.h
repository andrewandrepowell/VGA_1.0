/*
 * VGA.h
 *
 *  Created on: Oct 15, 2015
 *      Author: Andrew Powell
 */

#ifndef VGA_H_
#define VGA_H_

#include <stdint.h>
#include <string.h>

#define VGA_SCREEN_WIDTH 640
#define VGA_SCREEN_HEIGHT 480
#define VGA_BYTES_PER_PIXEL 2
#define VGA_BITS_PER_PIXEL_ELEMENT 4;
#define VGA_PIXELS_PER_FRAME VGA_SCREEN_WIDTH*VGA_SCREEN_HEIGHT
#define VGA_BYTES_PER_FRAME VGA_PIXELS_PER_FRAME*VGA_BYTES_PER_PIXEL
#define VGA_ADDR_ADDRESS_REG 0
#define VGA_ADDR_ERROR_REG 1
#define VGA_ADDR_START_REG 2
#define VGA_ADDR_START_REG_START_MASK (1<<0)

typedef struct vga_pixel {
	unsigned char b:VGA_BITS_PER_PIXEL_ELEMENT;
	unsigned char g:VGA_BITS_PER_PIXEL_ELEMENT;
	unsigned char r:VGA_BITS_PER_PIXEL_ELEMENT;
} vga_pixel;

typedef struct vga_frame {
	vga_pixel pixels[VGA_SCREEN_HEIGHT][VGA_SCREEN_WIDTH];
} vga_frame;

typedef struct vga {
	uint32_t* config_address;
	vga_frame* vga_frame_obj;
} vga;

/* Initializes a pixel. */
#define vga_pixel_setup(vga_pixel_obj,b_0,g_0,r_0) ({(vga_pixel_obj)->b = (b_0); (vga_pixel_obj)->g = (g_0); (vga_pixel_obj)->r = (r_0);})

/*
 * Sets up the vga driver. config_address refers to the address that allows access to
 * the VGA's config AXI4-Lite interface. vga_frame_obj sets the address of a buffer from
 * which the VGA peripheral will read so as to update the VGA display.
 */
void vga_setup(vga* vga_obj,uint32_t* config_address,vga_frame* vga_frame_obj);

/* Configures the VGA peripheral to either update the VGA display or stop. */
#define vga_set_start(vga_obj,val) ({(vga_obj)->config_address[VGA_ADDR_START_REG] = ((val))?1:0;})

/* Returns the address of the first pixel in a frame. */
#define vga_frame_get_pixel(vga_frame_obj) (vga_frame_obj)->pixels

/* Copies the contents of a frame to the buffer from which the VGA will be updated. */
#define vga_frame_draw(vga_frame_obj_0,vga_obj) memcpy((vga_obj)->vga_frame_obj,(vga_frame_obj_0),sizeof(vga_frame))

/* Clears frame. */
#define vga_frame_clear(vga_frame_obj) memset((vga_frame_obj),0,sizeof(vga_frame))

/* Draws filled circle in frame. */
void vga_frame_draw_circle_filled(vga_frame* vga_frame_obj,int x_0,int y_0,int radius,vga_pixel color);

/* Draws filled rectangle in frame. */
void vga_frame_draw_rectangle_filled(vga_frame* vga_frame_obj,int x_0,int y_0,int width,
		int height,vga_pixel color);

/* Determines whether a point is within the range of the VGA display. */
#define vga_is_within_borders_x(x) ((x)>=0)&&((x)<VGA_SCREEN_WIDTH)
#define vga_is_within_borders_y(y) ((y)>=0)&&((y)<VGA_SCREEN_HEIGHT)

#endif /* VGA_H_ */
