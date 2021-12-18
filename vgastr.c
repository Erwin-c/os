/*
 * vgastr.c
 *
 *  Created on: Dec 18, 2021
 *      Author: Erwin
 */

void _strwrite(char* string) {
  char* p_strdst = (char*)(0xb8000);  // Points to the address of video memory.
                                      // VESA standard.

  while (*string) {
    *p_strdst = *string++;
    p_strdst += 2;  // Jump color.
  }

  return;
}

void printf(char* fmt, ...) {
  _strwrite(fmt);

  return;
}
