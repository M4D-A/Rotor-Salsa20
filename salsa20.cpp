#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void u8_to_u32(uint8_t* in, uint32_t* out, uint32_t bytes){
    uint32_t i;
    for(i = 0; i < bytes; i+=4){
        out[i>>2] = (in[i] << 0) | (in[i+1] << 8) | (in[i+2] << 16) | (in[i+3] << 24); 
    }
}

void u32_to_u8(uint32_t* in, uint8_t* out, uint32_t words){
    uint32_t i;
    for(i = 0; i < words; ++i){
        out[i*4+0] = (in[i] >>  0) & 0xff;
        out[i*4+1] = (in[i] >>  8) & 0xff;
        out[i*4+2] = (in[i] >> 16) & 0xff;
        out[i*4+3] = (in[i] >> 24) & 0xff;
    }
}

void u64_to_u32(uint64_t in, uint32_t out[2]){
    out[0] = (in >> 32) & 0xffffffff;
    out[1] = in & 0xffffffff;
}

uint32_t rotl(uint32_t value, int shift){
  return (value << shift) | (value >> (32 - shift));
}

void quarterround(uint32_t *y0, uint32_t *y1, uint32_t *y2, uint32_t *y3){
  *y1 = *y1 ^ rotl(*y0 + *y3, 7);
  *y2 = *y2 ^ rotl(*y1 + *y0, 9);
  *y3 = *y3 ^ rotl(*y2 + *y1, 13);
  *y0 = *y0 ^ rotl(*y3 + *y2, 18);
}

void doubleround(uint32_t x[16]){
  quarterround(&x[0], &x[4], &x[8], &x[12]);
  quarterround(&x[5], &x[9], &x[13], &x[1]);
  quarterround(&x[10], &x[14], &x[2], &x[6]);
  quarterround(&x[15], &x[3], &x[7], &x[11]);

  quarterround(&x[0], &x[1], &x[2], &x[3]);
  quarterround(&x[5], &x[6], &x[7], &x[4]);
  quarterround(&x[10], &x[11], &x[8], &x[9]);
  quarterround(&x[15], &x[12], &x[13], &x[14]);
}

void state_hash(uint32_t state[16]){
  uint32_t copy[16];
  memcpy(copy, state, sizeof(copy));
  int i;
  for (i = 0; i < 10; ++i) {
    doubleround(state);
  }
  for (i = 0; i < 16; ++i) state[i] += copy[i];
}

void salsa_hash(uint32_t key[8], uint32_t nonce[2], uint32_t counter[2], uint32_t state[16]){
    int i;
    uint32_t magic[4] = {0x61707865, 0x3320646e, 0x79622d32, 0x6b206574};
    for (i = 0; i < 4; ++i) state[ 5*i] = magic[i];
    for (i = 0; i < 2; ++i) state[ 6+i] = nonce[i];
    for (i = 0; i < 2; ++i) state[ 8+i] = counter[i];
    for (i = 0; i < 4; ++i) state[ 1+i] = key[i];
    for (i = 0; i < 4; ++i) state[11+i] = key[4+i];
    state_hash(state);
}

void encrypt(uint8_t _key[32], uint8_t _nonce[8], uint8_t* in, uint8_t* out, uint32_t bytes){
    uint32_t state[16];
    uint32_t counter[2] = {0,0};
    uint32_t key[8];
    uint32_t nonce[2];
    uint8_t state8[64];

    uint32_t i;
    u8_to_u32(_key, key, 32);
    u8_to_u32(_nonce, nonce, 8);

    uint32_t blocks = bytes / 64;
    uint32_t remainder = bytes % 64;

    for(i = 0; i < blocks; ++i){
        salsa_hash(key, nonce, counter, state);
        u32_to_u8(state, state8, 16);
        for(int j = 0; j < 64; ++j) out[i*64+j] = in[i*64+j] ^ state8[j];
        counter[0] += 1;
        if(counter[0] == 0) counter[1] += 1;
    }
    if(remainder > 0){
      salsa_hash(key, nonce, counter, state);
      u32_to_u8(state, state8, 16);
      for(int j = 0; j < remainder; ++j) out[blocks*64+j] = in[blocks*64+j] ^ state8[j];
    }
}

int main(){
  uint32_t key[8] = {0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8};
  uint32_t nonce[2] = {0x9, 0xa};
  uint32_t counter[2] = {0xb, 0xc};
  uint32_t state[16] = {0};
  uint8_t state8[64] = {0};

  for(int j = 0; j < 8; j++){
    salsa_hash(key, nonce, counter, state);
    u32_to_u8(state, state8, 16);
    for(int i = 0; i < 64; ++i) printf("%02X", state8[63 - i]);
    printf("\n\n");

    for(int i = 0; i < 8; ++i) key[i] = key[i] * 2 + 1;
    for(int i = 0; i < 2; ++i) nonce[i] = nonce[i] * 2 + 1;
    for(int i = 0; i < 2; ++i) counter[i] = counter[i] * 2 + 1;
    for(int i = 0; i < 16; ++i) state[i] = 0;
  }


}

