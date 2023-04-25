#include <stdio.h>
//#include <libdeflate.h>
//#include <zlib.h>
#include <stdlib.h>
#include "return_codes.h"

#define BUFFER_SIZE 256
#if defined(ZLIB)
#include <zlib.h>
#elif defined(LIBDEFLATE)
    #include <libdeflate.h>
    #elif defined(ISAL)
    #include <include/igzip_lib.h>
    #else
    #error "Defined library is not supported"
#endif

int check_name(unsigned char const *name, unsigned char const *check_name, int start, int length) {
    for (int i = start; i < length + start; i++) {
        if (name[i - start] != check_name[i]) {
            return ERROR_UNSUPPORTED;
        }
    }

    return SUCCESS;
}

int input_in_buffer(FILE *input, unsigned char *buffer, unsigned int length) {
    unsigned long read = fread(buffer, 1, length, input);
    if (read != length) {
        fprintf(stderr, "error while reading a file\n");
        return ERROR_DATA_INVALID;
    }

    return SUCCESS;
}

unsigned int bytes_to_int(unsigned char const *bytes, int start, int n) {
    int result = bytes[start] << (n - 1) * 8;
    for (int i = n - 2; i >= 0; i--) {
        result = result | (bytes[start + n - i - 1] << i * 8);
    }
    return result;
}

int get_name_and_len_chunk(FILE *png, unsigned char *buffer, size_t *len) {
    int ret = input_in_buffer(png, buffer, 4);
    if (ret != SUCCESS) {
        return ret;
    }
    *len = bytes_to_int(buffer, 0, 4);
    ret = input_in_buffer(png, buffer, 4);
    if (ret != SUCCESS) {
        return ret;
    }
    return ret;
}

int check_png_signature(FILE *png, unsigned char *buffer) {
    unsigned char ok_signature[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
    fread(buffer, 1, 8, png);
    printf("%x %x %x %x %x %x %x %x", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6],
           buffer[7]);
    return check_name(buffer, ok_signature, 0, 8);
}


int read_IHDR(FILE *png, size_t *w, size_t *h, unsigned int *bit_depth, unsigned int *color_type,
              unsigned int *deflate,
              unsigned int *filter, unsigned int *interlace, unsigned char *buffer) {
    int ret = input_in_buffer(png, buffer, 13);
    if (ret != SUCCESS) {
        return ret;
    }
    *w = bytes_to_int(buffer, 0, 4);
    *h = bytes_to_int(buffer, 4, 4);
    *bit_depth = bytes_to_int(buffer, 8, 1);
    *color_type = bytes_to_int(buffer, 9, 1);
    *deflate = bytes_to_int(buffer, 10, 1);
    *filter = bytes_to_int(buffer, 11, 1);
    *interlace = bytes_to_int(buffer, 12, 1);
    input_in_buffer(png, buffer, 4);
//    printf("  \n IHDR  %d %d %d %d", buffer[0], buffer[1], buffer[2], buffer[3]); crc

    return SUCCESS;
}


int read_PLTE(FILE *png, size_t len, unsigned char pl[len], unsigned char *buffer) {
    int ret;
    for (size_t i = 0; i < len; i++) {
        ret = input_in_buffer(png, buffer, 1);
        if (ret != SUCCESS) {
            return ret;
        }
        pl[i] = buffer[0];
        if (i > 0 && i % 3 == 0) {
            printf("  \n Plte  %x %x %x %d", pl[i - 2], pl[i - 1], pl[i], i);
        }
    }
    ret = input_in_buffer(png, buffer, 4);
    if (ret != SUCCESS) {
        return ret;
    }

//    printf("  \n Plte  %x %x %x %x", buffer[0], buffer[1], buffer[2], buffer[3]); crc
    return SUCCESS;
}
int read_IDAT(FILE *png,unsigned char *buffer, unsigned char *data, size_t start, size_t n){
    int ret;
    for (size_t i = 0; i < n; i ++){
        ret = input_in_buffer(png, buffer, 1);
        if (ret != SUCCESS){
            return ret;
        }
        data[start + i] = buffer[0];
    }
    printf(" \n IDAT %x ", buffer[0]);

    return SUCCESS;
}
int read_png(FILE *png, unsigned char *buffer) {
    unsigned char ok_IHDR[4] = {0x49, 0x48, 0x44, 0x52};
    unsigned char ok_PLTE[4] = {0x50, 0x4c, 0x54, 0x45};
    unsigned char ok_IDAT[4] = {0x49 , 0x44 , 0x41 , 0x54};
    unsigned char ok_IEND[4] = {0x49 , 0x45 , 0x4e , 0x44};
    unsigned char *pl = (unsigned char *) malloc(256 * 3 * sizeof(unsigned char));

    size_t w, h, len;
    unsigned int bit_depth, color_type, deflate, filter, interlace, critical, public, reserved, unsafe_to_copy;
    int ret;


    ret = check_png_signature(png, buffer);
    if (ret != SUCCESS) {
        return ret;
    }
    ret = get_name_and_len_chunk(png, buffer, &len);
    if (ret != SUCCESS) {
        return ret;
    }
    if (len != 13) {
        return ERROR_DATA_INVALID;
    }
    if (check_name(buffer, ok_IHDR, 0, 4) != SUCCESS) {
        return ERROR_UNSUPPORTED;
    }
    ret = read_IHDR(png, &w, &h, &bit_depth, &color_type, &deflate, &filter, &interlace, buffer);
    if (ret != SUCCESS) {
        return ret;
    }
    printf("  \n IHDR %d %d %d %d %d %d %d ", w, h, bit_depth, color_type, deflate, filter, interlace);
    if (color_type == 3) {
        do {
            ret = get_name_and_len_chunk(png, buffer, &len);
            if (ret != SUCCESS) {
                return ret;
            }
            ret = check_name(buffer, ok_PLTE, 0, 4);
            if (ret == ERROR_UNSUPPORTED) {
                input_in_buffer(png, buffer, len);
                input_in_buffer(png, buffer, 4);
            }
        } while (ret == ERROR_UNSUPPORTED);
        if (len % 3 != 0) {
            return ERROR_DATA_INVALID;
        }
        ret = read_PLTE(png, len, pl, buffer);
        if (ret != SUCCESS) {
            return ret;
        }
    }
    unsigned char *data = (unsigned char *) malloc(0);
    size_t out_len = 0;
    do {
        ret = get_name_and_len_chunk(png, buffer, &len);
        if (ret != SUCCESS) {
            return ret;
        }
        ret = check_name(buffer, ok_IDAT, 0, 4);
        if (check_name(buffer, ok_IEND, 0, 4) == SUCCESS){
            ret = input_in_buffer(png, buffer, 4);
            if (ret != SUCCESS){
                return ret;
            }
            if (out_len > 0){
                return ERROR_DATA_INVALID;
            }

            break;
        }
        if (ret == ERROR_UNSUPPORTED ) {
            ret = input_in_buffer(png, buffer, len);

            if (ret != SUCCESS){
                return ret;
            }
            ret = input_in_buffer(png, buffer, 4);
            if (ret != SUCCESS){
                return ret;
            }

        } else{
            data = realloc(data, out_len + len);
            ret = read_IDAT(png, buffer, data, out_len, len);
            if (ret != SUCCESS){
                return ret;
            }
            out_len += len;
            ret = input_in_buffer(png, buffer, 4);
            if (ret != SUCCESS){
                return ret;
            }
        }

    } while (1);
    size_t koef = 1;
    if (color_type == 2){
        koef = 3;
    }
    unsigned char *data_dec = (unsigned char *) malloc(h + (w + 1));
    size_t len_th = h + (w + 1);
#ifdef ZLIB
    ret = uncompress(data_dec, &len_th, data, len);
#endif
    printf("\n %d", ret);
    return SUCCESS;
}

int main() {
    FILE *fp = fopen("/Users/tulenevvadim/Desktop/itmo/C:C++/HomeWork/untitled2/in1.png", "rb");
    unsigned char *buffer = (unsigned char *) malloc(BUFFER_SIZE * sizeof(unsigned char));;
    if (read_png(fp, buffer) != SUCCESS) {
        return 1;
    }
    fclose(fp);
    free(buffer);
    return 0;
}

