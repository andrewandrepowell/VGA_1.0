/*
 * VGA.c
 *
 *  Created on: Oct 15, 2015
 *      Author: Andrew Powell
 */
#include "VGA.h"

void vga_setup(vga* vga_obj,uint32_t* config_address,vga_frame* vga_frame_obj) {
	vga_obj->config_address = config_address;
	vga_obj->vga_frame_obj = vga_frame_obj;
	vga_frame_clear(vga_frame_obj);
	vga_obj->config_address[VGA_ADDR_ADDRESS_REG] = (uint32_t)vga_frame_obj;
	vga_set_start(vga_obj,1);
}

void vga_frame_draw_circle_filled(vga_frame* vga_frame_obj,int x_0,int y_0,int radius,vga_pixel color) {
	int x,y;
	int x_new,y_new;
	int radius_squared = radius*radius;
	for(y=-radius; y<=radius; y++) {
	    for(x=-radius; x<=radius; x++) {
	    	x_new = x + x_0;
	    	y_new = y + y_0;
	        if(vga_is_within_borders_x(x_new)&&
	        		vga_is_within_borders_y(y_new)&&
	        		(((x*x)+(y*y)) < radius_squared)) {
	        	vga_frame_get_pixel(vga_frame_obj)[y_new][x_new] = color;
	        }
	    }
	}
}

void vga_frame_draw_rectangle_filled(vga_frame* vga_frame_obj,int x_0,int y_0,int width,
		int height,vga_pixel color) {
	int x,y;
	int x_new,y_new;
	for(y=0; y<=height; y++) {
		for(x=0; x<=width; x++) {
			x_new = x + x_0;
			y_new = y + y_0;
			if (vga_is_within_borders_x(x_new)&&
	        		vga_is_within_borders_y(y_new)) {
				vga_frame_get_pixel(vga_frame_obj)[y_new][x_new] = color;
			}
		}
	}
}
