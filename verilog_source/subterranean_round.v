/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module subterranean_round
(
    input wire [256:0] a,
    input wire [32:0] din,
    output wire [256:0] o,
    output wire [31:0] dout
);

wire [256:0] a_after_chi_iota;
wire [256:0] a_after_theta;

// Chi and iota steps

assign a_after_chi_iota[0]     = ~(a[0]   ^   ((~a[1])     & a[2]));
assign a_after_chi_iota[254:1] = a[254:1] ^   ((~a[255:2]) & a[256:3]);
assign a_after_chi_iota[255]   = a[255]   ^   ((~a[256])   & a[0]);
assign a_after_chi_iota[256]   = a[256]   ^   ((~a[0])     & a[1]);

// Theta step

assign a_after_theta[12]  = a_after_chi_iota[12]  ^ a_after_chi_iota[15]  ^ a_after_chi_iota[20]  ^ din[0];
assign a_after_theta[56]  = a_after_chi_iota[56]  ^ a_after_chi_iota[59]  ^ a_after_chi_iota[64]  ^ din[1];
assign a_after_theta[90]  = a_after_chi_iota[90]  ^ a_after_chi_iota[93]  ^ a_after_chi_iota[98]  ^ din[2];
assign a_after_theta[163] = a_after_chi_iota[163] ^ a_after_chi_iota[166] ^ a_after_chi_iota[171] ^ din[3];
assign a_after_theta[161] = a_after_chi_iota[161] ^ a_after_chi_iota[164] ^ a_after_chi_iota[169] ^ din[4];
assign a_after_theta[66]  = a_after_chi_iota[66]  ^ a_after_chi_iota[69]  ^ a_after_chi_iota[74]  ^ din[5];
assign a_after_theta[51]  = a_after_chi_iota[51]  ^ a_after_chi_iota[54]  ^ a_after_chi_iota[59]  ^ din[6];
assign a_after_theta[238] = a_after_chi_iota[238] ^ a_after_chi_iota[241] ^ a_after_chi_iota[246] ^ din[7];
assign a_after_theta[254] = a_after_chi_iota[254] ^ a_after_chi_iota[0]   ^ a_after_chi_iota[5]   ^ din[8];
assign a_after_theta[243] = a_after_chi_iota[243] ^ a_after_chi_iota[246] ^ a_after_chi_iota[251] ^ din[9];
assign a_after_theta[106] = a_after_chi_iota[106] ^ a_after_chi_iota[109] ^ a_after_chi_iota[114] ^ din[10];
assign a_after_theta[152] = a_after_chi_iota[152] ^ a_after_chi_iota[155] ^ a_after_chi_iota[160] ^ din[11];
assign a_after_theta[24]  = a_after_chi_iota[24]  ^ a_after_chi_iota[27]  ^ a_after_chi_iota[32]  ^ din[12];
assign a_after_theta[112] = a_after_chi_iota[112] ^ a_after_chi_iota[115] ^ a_after_chi_iota[120] ^ din[13];
assign a_after_theta[180] = a_after_chi_iota[180] ^ a_after_chi_iota[183] ^ a_after_chi_iota[188] ^ din[14];
assign a_after_theta[69]  = a_after_chi_iota[69]  ^ a_after_chi_iota[72]  ^ a_after_chi_iota[77]  ^ din[15];
assign a_after_theta[65]  = a_after_chi_iota[65]  ^ a_after_chi_iota[68]  ^ a_after_chi_iota[73]  ^ din[16];
assign a_after_theta[132] = a_after_chi_iota[132] ^ a_after_chi_iota[135] ^ a_after_chi_iota[140] ^ din[17];
assign a_after_theta[102] = a_after_chi_iota[102] ^ a_after_chi_iota[105] ^ a_after_chi_iota[110] ^ din[18];
assign a_after_theta[219] = a_after_chi_iota[219] ^ a_after_chi_iota[222] ^ a_after_chi_iota[227] ^ din[19];
assign a_after_theta[251] = a_after_chi_iota[251] ^ a_after_chi_iota[254] ^ a_after_chi_iota[2]   ^ din[20];
assign a_after_theta[229] = a_after_chi_iota[229] ^ a_after_chi_iota[232] ^ a_after_chi_iota[237] ^ din[21];
assign a_after_theta[212] = a_after_chi_iota[212] ^ a_after_chi_iota[215] ^ a_after_chi_iota[220] ^ din[22];
assign a_after_theta[47]  = a_after_chi_iota[47]  ^ a_after_chi_iota[50]  ^ a_after_chi_iota[55]  ^ din[23];
assign a_after_theta[48]  = a_after_chi_iota[48]  ^ a_after_chi_iota[51]  ^ a_after_chi_iota[56]  ^ din[24];
assign a_after_theta[224] = a_after_chi_iota[224] ^ a_after_chi_iota[227] ^ a_after_chi_iota[232] ^ din[25];
assign a_after_theta[103] = a_after_chi_iota[103] ^ a_after_chi_iota[106] ^ a_after_chi_iota[111] ^ din[26];
assign a_after_theta[138] = a_after_chi_iota[138] ^ a_after_chi_iota[141] ^ a_after_chi_iota[146] ^ din[27];
assign a_after_theta[130] = a_after_chi_iota[130] ^ a_after_chi_iota[133] ^ a_after_chi_iota[138] ^ din[28];
assign a_after_theta[7]   = a_after_chi_iota[7]   ^ a_after_chi_iota[10]  ^ a_after_chi_iota[15]  ^ din[29];
assign a_after_theta[204] = a_after_chi_iota[204] ^ a_after_chi_iota[207] ^ a_after_chi_iota[212] ^ din[30];
assign a_after_theta[181] = a_after_chi_iota[181] ^ a_after_chi_iota[184] ^ a_after_chi_iota[189] ^ din[31];
assign a_after_theta[245] = a_after_chi_iota[245] ^ a_after_chi_iota[248] ^ a_after_chi_iota[253] ^ din[32];

assign a_after_theta[0] = a_after_chi_iota[0] ^ a_after_chi_iota[3] ^ a_after_chi_iota[8];
assign a_after_theta[36] = a_after_chi_iota[36] ^ a_after_chi_iota[39] ^ a_after_chi_iota[44];
assign a_after_theta[60] = a_after_chi_iota[60] ^ a_after_chi_iota[63] ^ a_after_chi_iota[68];
assign a_after_theta[72] = a_after_chi_iota[72] ^ a_after_chi_iota[75] ^ a_after_chi_iota[80];
assign a_after_theta[84] = a_after_chi_iota[84] ^ a_after_chi_iota[87] ^ a_after_chi_iota[92];
assign a_after_theta[96] = a_after_chi_iota[96] ^ a_after_chi_iota[99] ^ a_after_chi_iota[104];
assign a_after_theta[108] = a_after_chi_iota[108] ^ a_after_chi_iota[111] ^ a_after_chi_iota[116];
assign a_after_theta[120] = a_after_chi_iota[120] ^ a_after_chi_iota[123] ^ a_after_chi_iota[128];
assign a_after_theta[144] = a_after_chi_iota[144] ^ a_after_chi_iota[147] ^ a_after_chi_iota[152];
assign a_after_theta[156] = a_after_chi_iota[156] ^ a_after_chi_iota[159] ^ a_after_chi_iota[164];
assign a_after_theta[168] = a_after_chi_iota[168] ^ a_after_chi_iota[171] ^ a_after_chi_iota[176];
assign a_after_theta[192] = a_after_chi_iota[192] ^ a_after_chi_iota[195] ^ a_after_chi_iota[200];
assign a_after_theta[216] = a_after_chi_iota[216] ^ a_after_chi_iota[219] ^ a_after_chi_iota[224];
assign a_after_theta[228] = a_after_chi_iota[228] ^ a_after_chi_iota[231] ^ a_after_chi_iota[236];
assign a_after_theta[240] = a_after_chi_iota[240] ^ a_after_chi_iota[243] ^ a_after_chi_iota[248];
assign a_after_theta[252] = a_after_chi_iota[252] ^ a_after_chi_iota[255] ^ a_after_chi_iota[3];
assign a_after_theta[19] = a_after_chi_iota[19] ^ a_after_chi_iota[22] ^ a_after_chi_iota[27];
assign a_after_theta[31] = a_after_chi_iota[31] ^ a_after_chi_iota[34] ^ a_after_chi_iota[39];
assign a_after_theta[43] = a_after_chi_iota[43] ^ a_after_chi_iota[46] ^ a_after_chi_iota[51];
assign a_after_theta[55] = a_after_chi_iota[55] ^ a_after_chi_iota[58] ^ a_after_chi_iota[63];
assign a_after_theta[67] = a_after_chi_iota[67] ^ a_after_chi_iota[70] ^ a_after_chi_iota[75];
assign a_after_theta[79] = a_after_chi_iota[79] ^ a_after_chi_iota[82] ^ a_after_chi_iota[87];
assign a_after_theta[91] = a_after_chi_iota[91] ^ a_after_chi_iota[94] ^ a_after_chi_iota[99];
assign a_after_theta[115] = a_after_chi_iota[115] ^ a_after_chi_iota[118] ^ a_after_chi_iota[123];
assign a_after_theta[127] = a_after_chi_iota[127] ^ a_after_chi_iota[130] ^ a_after_chi_iota[135];
assign a_after_theta[139] = a_after_chi_iota[139] ^ a_after_chi_iota[142] ^ a_after_chi_iota[147];
assign a_after_theta[151] = a_after_chi_iota[151] ^ a_after_chi_iota[154] ^ a_after_chi_iota[159];
assign a_after_theta[175] = a_after_chi_iota[175] ^ a_after_chi_iota[178] ^ a_after_chi_iota[183];
assign a_after_theta[187] = a_after_chi_iota[187] ^ a_after_chi_iota[190] ^ a_after_chi_iota[195];
assign a_after_theta[199] = a_after_chi_iota[199] ^ a_after_chi_iota[202] ^ a_after_chi_iota[207];
assign a_after_theta[211] = a_after_chi_iota[211] ^ a_after_chi_iota[214] ^ a_after_chi_iota[219];
assign a_after_theta[223] = a_after_chi_iota[223] ^ a_after_chi_iota[226] ^ a_after_chi_iota[231];
assign a_after_theta[235] = a_after_chi_iota[235] ^ a_after_chi_iota[238] ^ a_after_chi_iota[243];
assign a_after_theta[247] = a_after_chi_iota[247] ^ a_after_chi_iota[250] ^ a_after_chi_iota[255];
assign a_after_theta[2] = a_after_chi_iota[2] ^ a_after_chi_iota[5] ^ a_after_chi_iota[10];
assign a_after_theta[14] = a_after_chi_iota[14] ^ a_after_chi_iota[17] ^ a_after_chi_iota[22];
assign a_after_theta[26] = a_after_chi_iota[26] ^ a_after_chi_iota[29] ^ a_after_chi_iota[34];
assign a_after_theta[38] = a_after_chi_iota[38] ^ a_after_chi_iota[41] ^ a_after_chi_iota[46];
assign a_after_theta[50] = a_after_chi_iota[50] ^ a_after_chi_iota[53] ^ a_after_chi_iota[58];
assign a_after_theta[62] = a_after_chi_iota[62] ^ a_after_chi_iota[65] ^ a_after_chi_iota[70];
assign a_after_theta[74] = a_after_chi_iota[74] ^ a_after_chi_iota[77] ^ a_after_chi_iota[82];
assign a_after_theta[86] = a_after_chi_iota[86] ^ a_after_chi_iota[89] ^ a_after_chi_iota[94];
assign a_after_theta[98] = a_after_chi_iota[98] ^ a_after_chi_iota[101] ^ a_after_chi_iota[106];
assign a_after_theta[110] = a_after_chi_iota[110] ^ a_after_chi_iota[113] ^ a_after_chi_iota[118];
assign a_after_theta[122] = a_after_chi_iota[122] ^ a_after_chi_iota[125] ^ a_after_chi_iota[130];
assign a_after_theta[134] = a_after_chi_iota[134] ^ a_after_chi_iota[137] ^ a_after_chi_iota[142];
assign a_after_theta[146] = a_after_chi_iota[146] ^ a_after_chi_iota[149] ^ a_after_chi_iota[154];
assign a_after_theta[158] = a_after_chi_iota[158] ^ a_after_chi_iota[161] ^ a_after_chi_iota[166];
assign a_after_theta[170] = a_after_chi_iota[170] ^ a_after_chi_iota[173] ^ a_after_chi_iota[178];
assign a_after_theta[182] = a_after_chi_iota[182] ^ a_after_chi_iota[185] ^ a_after_chi_iota[190];
assign a_after_theta[194] = a_after_chi_iota[194] ^ a_after_chi_iota[197] ^ a_after_chi_iota[202];
assign a_after_theta[206] = a_after_chi_iota[206] ^ a_after_chi_iota[209] ^ a_after_chi_iota[214];
assign a_after_theta[218] = a_after_chi_iota[218] ^ a_after_chi_iota[221] ^ a_after_chi_iota[226];
assign a_after_theta[230] = a_after_chi_iota[230] ^ a_after_chi_iota[233] ^ a_after_chi_iota[238];
assign a_after_theta[242] = a_after_chi_iota[242] ^ a_after_chi_iota[245] ^ a_after_chi_iota[250];
assign a_after_theta[9] = a_after_chi_iota[9] ^ a_after_chi_iota[12] ^ a_after_chi_iota[17];
assign a_after_theta[21] = a_after_chi_iota[21] ^ a_after_chi_iota[24] ^ a_after_chi_iota[29];
assign a_after_theta[33] = a_after_chi_iota[33] ^ a_after_chi_iota[36] ^ a_after_chi_iota[41];
assign a_after_theta[45] = a_after_chi_iota[45] ^ a_after_chi_iota[48] ^ a_after_chi_iota[53];
assign a_after_theta[57] = a_after_chi_iota[57] ^ a_after_chi_iota[60] ^ a_after_chi_iota[65];
assign a_after_theta[81] = a_after_chi_iota[81] ^ a_after_chi_iota[84] ^ a_after_chi_iota[89];
assign a_after_theta[93] = a_after_chi_iota[93] ^ a_after_chi_iota[96] ^ a_after_chi_iota[101];
assign a_after_theta[105] = a_after_chi_iota[105] ^ a_after_chi_iota[108] ^ a_after_chi_iota[113];
assign a_after_theta[117] = a_after_chi_iota[117] ^ a_after_chi_iota[120] ^ a_after_chi_iota[125];
assign a_after_theta[129] = a_after_chi_iota[129] ^ a_after_chi_iota[132] ^ a_after_chi_iota[137];
assign a_after_theta[141] = a_after_chi_iota[141] ^ a_after_chi_iota[144] ^ a_after_chi_iota[149];
assign a_after_theta[153] = a_after_chi_iota[153] ^ a_after_chi_iota[156] ^ a_after_chi_iota[161];
assign a_after_theta[165] = a_after_chi_iota[165] ^ a_after_chi_iota[168] ^ a_after_chi_iota[173];
assign a_after_theta[177] = a_after_chi_iota[177] ^ a_after_chi_iota[180] ^ a_after_chi_iota[185];
assign a_after_theta[189] = a_after_chi_iota[189] ^ a_after_chi_iota[192] ^ a_after_chi_iota[197];
assign a_after_theta[201] = a_after_chi_iota[201] ^ a_after_chi_iota[204] ^ a_after_chi_iota[209];
assign a_after_theta[213] = a_after_chi_iota[213] ^ a_after_chi_iota[216] ^ a_after_chi_iota[221];
assign a_after_theta[225] = a_after_chi_iota[225] ^ a_after_chi_iota[228] ^ a_after_chi_iota[233];
assign a_after_theta[237] = a_after_chi_iota[237] ^ a_after_chi_iota[240] ^ a_after_chi_iota[245];
assign a_after_theta[249] = a_after_chi_iota[249] ^ a_after_chi_iota[252] ^ a_after_chi_iota[0];
assign a_after_theta[4] = a_after_chi_iota[4] ^ a_after_chi_iota[7] ^ a_after_chi_iota[12];
assign a_after_theta[16] = a_after_chi_iota[16] ^ a_after_chi_iota[19] ^ a_after_chi_iota[24];
assign a_after_theta[28] = a_after_chi_iota[28] ^ a_after_chi_iota[31] ^ a_after_chi_iota[36];
assign a_after_theta[40] = a_after_chi_iota[40] ^ a_after_chi_iota[43] ^ a_after_chi_iota[48];
assign a_after_theta[52] = a_after_chi_iota[52] ^ a_after_chi_iota[55] ^ a_after_chi_iota[60];
assign a_after_theta[64] = a_after_chi_iota[64] ^ a_after_chi_iota[67] ^ a_after_chi_iota[72];
assign a_after_theta[76] = a_after_chi_iota[76] ^ a_after_chi_iota[79] ^ a_after_chi_iota[84];
assign a_after_theta[88] = a_after_chi_iota[88] ^ a_after_chi_iota[91] ^ a_after_chi_iota[96];
assign a_after_theta[100] = a_after_chi_iota[100] ^ a_after_chi_iota[103] ^ a_after_chi_iota[108];
assign a_after_theta[124] = a_after_chi_iota[124] ^ a_after_chi_iota[127] ^ a_after_chi_iota[132];
assign a_after_theta[136] = a_after_chi_iota[136] ^ a_after_chi_iota[139] ^ a_after_chi_iota[144];
assign a_after_theta[148] = a_after_chi_iota[148] ^ a_after_chi_iota[151] ^ a_after_chi_iota[156];
assign a_after_theta[160] = a_after_chi_iota[160] ^ a_after_chi_iota[163] ^ a_after_chi_iota[168];
assign a_after_theta[172] = a_after_chi_iota[172] ^ a_after_chi_iota[175] ^ a_after_chi_iota[180];
assign a_after_theta[184] = a_after_chi_iota[184] ^ a_after_chi_iota[187] ^ a_after_chi_iota[192];
assign a_after_theta[196] = a_after_chi_iota[196] ^ a_after_chi_iota[199] ^ a_after_chi_iota[204];
assign a_after_theta[208] = a_after_chi_iota[208] ^ a_after_chi_iota[211] ^ a_after_chi_iota[216];
assign a_after_theta[220] = a_after_chi_iota[220] ^ a_after_chi_iota[223] ^ a_after_chi_iota[228];
assign a_after_theta[232] = a_after_chi_iota[232] ^ a_after_chi_iota[235] ^ a_after_chi_iota[240];
assign a_after_theta[244] = a_after_chi_iota[244] ^ a_after_chi_iota[247] ^ a_after_chi_iota[252];
assign a_after_theta[256] = a_after_chi_iota[256] ^ a_after_chi_iota[2] ^ a_after_chi_iota[7];
assign a_after_theta[11] = a_after_chi_iota[11] ^ a_after_chi_iota[14] ^ a_after_chi_iota[19];
assign a_after_theta[23] = a_after_chi_iota[23] ^ a_after_chi_iota[26] ^ a_after_chi_iota[31];
assign a_after_theta[35] = a_after_chi_iota[35] ^ a_after_chi_iota[38] ^ a_after_chi_iota[43];
assign a_after_theta[59] = a_after_chi_iota[59] ^ a_after_chi_iota[62] ^ a_after_chi_iota[67];
assign a_after_theta[71] = a_after_chi_iota[71] ^ a_after_chi_iota[74] ^ a_after_chi_iota[79];
assign a_after_theta[83] = a_after_chi_iota[83] ^ a_after_chi_iota[86] ^ a_after_chi_iota[91];
assign a_after_theta[95] = a_after_chi_iota[95] ^ a_after_chi_iota[98] ^ a_after_chi_iota[103];
assign a_after_theta[107] = a_after_chi_iota[107] ^ a_after_chi_iota[110] ^ a_after_chi_iota[115];
assign a_after_theta[119] = a_after_chi_iota[119] ^ a_after_chi_iota[122] ^ a_after_chi_iota[127];
assign a_after_theta[131] = a_after_chi_iota[131] ^ a_after_chi_iota[134] ^ a_after_chi_iota[139];
assign a_after_theta[143] = a_after_chi_iota[143] ^ a_after_chi_iota[146] ^ a_after_chi_iota[151];
assign a_after_theta[155] = a_after_chi_iota[155] ^ a_after_chi_iota[158] ^ a_after_chi_iota[163];
assign a_after_theta[167] = a_after_chi_iota[167] ^ a_after_chi_iota[170] ^ a_after_chi_iota[175];
assign a_after_theta[179] = a_after_chi_iota[179] ^ a_after_chi_iota[182] ^ a_after_chi_iota[187];
assign a_after_theta[191] = a_after_chi_iota[191] ^ a_after_chi_iota[194] ^ a_after_chi_iota[199];
assign a_after_theta[203] = a_after_chi_iota[203] ^ a_after_chi_iota[206] ^ a_after_chi_iota[211];
assign a_after_theta[215] = a_after_chi_iota[215] ^ a_after_chi_iota[218] ^ a_after_chi_iota[223];
assign a_after_theta[227] = a_after_chi_iota[227] ^ a_after_chi_iota[230] ^ a_after_chi_iota[235];
assign a_after_theta[239] = a_after_chi_iota[239] ^ a_after_chi_iota[242] ^ a_after_chi_iota[247];
assign a_after_theta[6] = a_after_chi_iota[6] ^ a_after_chi_iota[9] ^ a_after_chi_iota[14];
assign a_after_theta[18] = a_after_chi_iota[18] ^ a_after_chi_iota[21] ^ a_after_chi_iota[26];
assign a_after_theta[30] = a_after_chi_iota[30] ^ a_after_chi_iota[33] ^ a_after_chi_iota[38];
assign a_after_theta[42] = a_after_chi_iota[42] ^ a_after_chi_iota[45] ^ a_after_chi_iota[50];
assign a_after_theta[54] = a_after_chi_iota[54] ^ a_after_chi_iota[57] ^ a_after_chi_iota[62];
assign a_after_theta[78] = a_after_chi_iota[78] ^ a_after_chi_iota[81] ^ a_after_chi_iota[86];
assign a_after_theta[114] = a_after_chi_iota[114] ^ a_after_chi_iota[117] ^ a_after_chi_iota[122];
assign a_after_theta[126] = a_after_chi_iota[126] ^ a_after_chi_iota[129] ^ a_after_chi_iota[134];
assign a_after_theta[150] = a_after_chi_iota[150] ^ a_after_chi_iota[153] ^ a_after_chi_iota[158];
assign a_after_theta[162] = a_after_chi_iota[162] ^ a_after_chi_iota[165] ^ a_after_chi_iota[170];
assign a_after_theta[174] = a_after_chi_iota[174] ^ a_after_chi_iota[177] ^ a_after_chi_iota[182];
assign a_after_theta[186] = a_after_chi_iota[186] ^ a_after_chi_iota[189] ^ a_after_chi_iota[194];
assign a_after_theta[198] = a_after_chi_iota[198] ^ a_after_chi_iota[201] ^ a_after_chi_iota[206];
assign a_after_theta[210] = a_after_chi_iota[210] ^ a_after_chi_iota[213] ^ a_after_chi_iota[218];
assign a_after_theta[222] = a_after_chi_iota[222] ^ a_after_chi_iota[225] ^ a_after_chi_iota[230];
assign a_after_theta[234] = a_after_chi_iota[234] ^ a_after_chi_iota[237] ^ a_after_chi_iota[242];
assign a_after_theta[246] = a_after_chi_iota[246] ^ a_after_chi_iota[249] ^ a_after_chi_iota[254];
assign a_after_theta[1] = a_after_chi_iota[1] ^ a_after_chi_iota[4] ^ a_after_chi_iota[9];
assign a_after_theta[13] = a_after_chi_iota[13] ^ a_after_chi_iota[16] ^ a_after_chi_iota[21];
assign a_after_theta[25] = a_after_chi_iota[25] ^ a_after_chi_iota[28] ^ a_after_chi_iota[33];
assign a_after_theta[37] = a_after_chi_iota[37] ^ a_after_chi_iota[40] ^ a_after_chi_iota[45];
assign a_after_theta[49] = a_after_chi_iota[49] ^ a_after_chi_iota[52] ^ a_after_chi_iota[57];
assign a_after_theta[61] = a_after_chi_iota[61] ^ a_after_chi_iota[64] ^ a_after_chi_iota[69];
assign a_after_theta[73] = a_after_chi_iota[73] ^ a_after_chi_iota[76] ^ a_after_chi_iota[81];
assign a_after_theta[85] = a_after_chi_iota[85] ^ a_after_chi_iota[88] ^ a_after_chi_iota[93];
assign a_after_theta[97] = a_after_chi_iota[97] ^ a_after_chi_iota[100] ^ a_after_chi_iota[105];
assign a_after_theta[109] = a_after_chi_iota[109] ^ a_after_chi_iota[112] ^ a_after_chi_iota[117];
assign a_after_theta[121] = a_after_chi_iota[121] ^ a_after_chi_iota[124] ^ a_after_chi_iota[129];
assign a_after_theta[133] = a_after_chi_iota[133] ^ a_after_chi_iota[136] ^ a_after_chi_iota[141];
assign a_after_theta[145] = a_after_chi_iota[145] ^ a_after_chi_iota[148] ^ a_after_chi_iota[153];
assign a_after_theta[157] = a_after_chi_iota[157] ^ a_after_chi_iota[160] ^ a_after_chi_iota[165];
assign a_after_theta[169] = a_after_chi_iota[169] ^ a_after_chi_iota[172] ^ a_after_chi_iota[177];
assign a_after_theta[193] = a_after_chi_iota[193] ^ a_after_chi_iota[196] ^ a_after_chi_iota[201];
assign a_after_theta[205] = a_after_chi_iota[205] ^ a_after_chi_iota[208] ^ a_after_chi_iota[213];
assign a_after_theta[217] = a_after_chi_iota[217] ^ a_after_chi_iota[220] ^ a_after_chi_iota[225];
assign a_after_theta[241] = a_after_chi_iota[241] ^ a_after_chi_iota[244] ^ a_after_chi_iota[249];
assign a_after_theta[253] = a_after_chi_iota[253] ^ a_after_chi_iota[256] ^ a_after_chi_iota[4];
assign a_after_theta[8] = a_after_chi_iota[8] ^ a_after_chi_iota[11] ^ a_after_chi_iota[16];
assign a_after_theta[20] = a_after_chi_iota[20] ^ a_after_chi_iota[23] ^ a_after_chi_iota[28];
assign a_after_theta[32] = a_after_chi_iota[32] ^ a_after_chi_iota[35] ^ a_after_chi_iota[40];
assign a_after_theta[44] = a_after_chi_iota[44] ^ a_after_chi_iota[47] ^ a_after_chi_iota[52];
assign a_after_theta[68] = a_after_chi_iota[68] ^ a_after_chi_iota[71] ^ a_after_chi_iota[76];
assign a_after_theta[80] = a_after_chi_iota[80] ^ a_after_chi_iota[83] ^ a_after_chi_iota[88];
assign a_after_theta[92] = a_after_chi_iota[92] ^ a_after_chi_iota[95] ^ a_after_chi_iota[100];
assign a_after_theta[104] = a_after_chi_iota[104] ^ a_after_chi_iota[107] ^ a_after_chi_iota[112];
assign a_after_theta[116] = a_after_chi_iota[116] ^ a_after_chi_iota[119] ^ a_after_chi_iota[124];
assign a_after_theta[128] = a_after_chi_iota[128] ^ a_after_chi_iota[131] ^ a_after_chi_iota[136];
assign a_after_theta[140] = a_after_chi_iota[140] ^ a_after_chi_iota[143] ^ a_after_chi_iota[148];
assign a_after_theta[164] = a_after_chi_iota[164] ^ a_after_chi_iota[167] ^ a_after_chi_iota[172];
assign a_after_theta[176] = a_after_chi_iota[176] ^ a_after_chi_iota[179] ^ a_after_chi_iota[184];
assign a_after_theta[188] = a_after_chi_iota[188] ^ a_after_chi_iota[191] ^ a_after_chi_iota[196];
assign a_after_theta[200] = a_after_chi_iota[200] ^ a_after_chi_iota[203] ^ a_after_chi_iota[208];
assign a_after_theta[236] = a_after_chi_iota[236] ^ a_after_chi_iota[239] ^ a_after_chi_iota[244];
assign a_after_theta[248] = a_after_chi_iota[248] ^ a_after_chi_iota[251] ^ a_after_chi_iota[256];
assign a_after_theta[3] = a_after_chi_iota[3] ^ a_after_chi_iota[6] ^ a_after_chi_iota[11];
assign a_after_theta[15] = a_after_chi_iota[15] ^ a_after_chi_iota[18] ^ a_after_chi_iota[23];
assign a_after_theta[27] = a_after_chi_iota[27] ^ a_after_chi_iota[30] ^ a_after_chi_iota[35];
assign a_after_theta[39] = a_after_chi_iota[39] ^ a_after_chi_iota[42] ^ a_after_chi_iota[47];
assign a_after_theta[63] = a_after_chi_iota[63] ^ a_after_chi_iota[66] ^ a_after_chi_iota[71];
assign a_after_theta[75] = a_after_chi_iota[75] ^ a_after_chi_iota[78] ^ a_after_chi_iota[83];
assign a_after_theta[87] = a_after_chi_iota[87] ^ a_after_chi_iota[90] ^ a_after_chi_iota[95];
assign a_after_theta[99] = a_after_chi_iota[99] ^ a_after_chi_iota[102] ^ a_after_chi_iota[107];
assign a_after_theta[111] = a_after_chi_iota[111] ^ a_after_chi_iota[114] ^ a_after_chi_iota[119];
assign a_after_theta[123] = a_after_chi_iota[123] ^ a_after_chi_iota[126] ^ a_after_chi_iota[131];
assign a_after_theta[135] = a_after_chi_iota[135] ^ a_after_chi_iota[138] ^ a_after_chi_iota[143];
assign a_after_theta[147] = a_after_chi_iota[147] ^ a_after_chi_iota[150] ^ a_after_chi_iota[155];
assign a_after_theta[159] = a_after_chi_iota[159] ^ a_after_chi_iota[162] ^ a_after_chi_iota[167];
assign a_after_theta[171] = a_after_chi_iota[171] ^ a_after_chi_iota[174] ^ a_after_chi_iota[179];
assign a_after_theta[183] = a_after_chi_iota[183] ^ a_after_chi_iota[186] ^ a_after_chi_iota[191];
assign a_after_theta[195] = a_after_chi_iota[195] ^ a_after_chi_iota[198] ^ a_after_chi_iota[203];
assign a_after_theta[207] = a_after_chi_iota[207] ^ a_after_chi_iota[210] ^ a_after_chi_iota[215];
assign a_after_theta[231] = a_after_chi_iota[231] ^ a_after_chi_iota[234] ^ a_after_chi_iota[239];
assign a_after_theta[255] = a_after_chi_iota[255] ^ a_after_chi_iota[1] ^ a_after_chi_iota[6];
assign a_after_theta[10] = a_after_chi_iota[10] ^ a_after_chi_iota[13] ^ a_after_chi_iota[18];
assign a_after_theta[22] = a_after_chi_iota[22] ^ a_after_chi_iota[25] ^ a_after_chi_iota[30];
assign a_after_theta[34] = a_after_chi_iota[34] ^ a_after_chi_iota[37] ^ a_after_chi_iota[42];
assign a_after_theta[46] = a_after_chi_iota[46] ^ a_after_chi_iota[49] ^ a_after_chi_iota[54];
assign a_after_theta[58] = a_after_chi_iota[58] ^ a_after_chi_iota[61] ^ a_after_chi_iota[66];
assign a_after_theta[70] = a_after_chi_iota[70] ^ a_after_chi_iota[73] ^ a_after_chi_iota[78];
assign a_after_theta[82] = a_after_chi_iota[82] ^ a_after_chi_iota[85] ^ a_after_chi_iota[90];
assign a_after_theta[94] = a_after_chi_iota[94] ^ a_after_chi_iota[97] ^ a_after_chi_iota[102];
assign a_after_theta[118] = a_after_chi_iota[118] ^ a_after_chi_iota[121] ^ a_after_chi_iota[126];
assign a_after_theta[142] = a_after_chi_iota[142] ^ a_after_chi_iota[145] ^ a_after_chi_iota[150];
assign a_after_theta[154] = a_after_chi_iota[154] ^ a_after_chi_iota[157] ^ a_after_chi_iota[162];
assign a_after_theta[166] = a_after_chi_iota[166] ^ a_after_chi_iota[169] ^ a_after_chi_iota[174];
assign a_after_theta[178] = a_after_chi_iota[178] ^ a_after_chi_iota[181] ^ a_after_chi_iota[186];
assign a_after_theta[190] = a_after_chi_iota[190] ^ a_after_chi_iota[193] ^ a_after_chi_iota[198];
assign a_after_theta[202] = a_after_chi_iota[202] ^ a_after_chi_iota[205] ^ a_after_chi_iota[210];
assign a_after_theta[214] = a_after_chi_iota[214] ^ a_after_chi_iota[217] ^ a_after_chi_iota[222];
assign a_after_theta[226] = a_after_chi_iota[226] ^ a_after_chi_iota[229] ^ a_after_chi_iota[234];
assign a_after_theta[250] = a_after_chi_iota[250] ^ a_after_chi_iota[253] ^ a_after_chi_iota[1];
assign a_after_theta[5] = a_after_chi_iota[5] ^ a_after_chi_iota[8] ^ a_after_chi_iota[13];
assign a_after_theta[17] = a_after_chi_iota[17] ^ a_after_chi_iota[20] ^ a_after_chi_iota[25];
assign a_after_theta[29] = a_after_chi_iota[29] ^ a_after_chi_iota[32] ^ a_after_chi_iota[37];
assign a_after_theta[41] = a_after_chi_iota[41] ^ a_after_chi_iota[44] ^ a_after_chi_iota[49];
assign a_after_theta[53] = a_after_chi_iota[53] ^ a_after_chi_iota[56] ^ a_after_chi_iota[61];
assign a_after_theta[77] = a_after_chi_iota[77] ^ a_after_chi_iota[80] ^ a_after_chi_iota[85];
assign a_after_theta[89] = a_after_chi_iota[89] ^ a_after_chi_iota[92] ^ a_after_chi_iota[97];
assign a_after_theta[101] = a_after_chi_iota[101] ^ a_after_chi_iota[104] ^ a_after_chi_iota[109];
assign a_after_theta[113] = a_after_chi_iota[113] ^ a_after_chi_iota[116] ^ a_after_chi_iota[121];
assign a_after_theta[125] = a_after_chi_iota[125] ^ a_after_chi_iota[128] ^ a_after_chi_iota[133];
assign a_after_theta[137] = a_after_chi_iota[137] ^ a_after_chi_iota[140] ^ a_after_chi_iota[145];
assign a_after_theta[149] = a_after_chi_iota[149] ^ a_after_chi_iota[152] ^ a_after_chi_iota[157];
assign a_after_theta[173] = a_after_chi_iota[173] ^ a_after_chi_iota[176] ^ a_after_chi_iota[181];
assign a_after_theta[185] = a_after_chi_iota[185] ^ a_after_chi_iota[188] ^ a_after_chi_iota[193];
assign a_after_theta[197] = a_after_chi_iota[197] ^ a_after_chi_iota[200] ^ a_after_chi_iota[205];
assign a_after_theta[209] = a_after_chi_iota[209] ^ a_after_chi_iota[212] ^ a_after_chi_iota[217];
assign a_after_theta[221] = a_after_chi_iota[221] ^ a_after_chi_iota[224] ^ a_after_chi_iota[229];
assign a_after_theta[233] = a_after_chi_iota[233] ^ a_after_chi_iota[236] ^ a_after_chi_iota[241];

// Pi step and output

generate
    genvar gen_j;
    for (gen_j = 0; gen_j < 257; gen_j = gen_j + 1) begin: pi_step
        assign o[gen_j] = a_after_theta[(12*gen_j) % 257];
    end
endgenerate


// Extract output

assign dout[0]  = a[1]   ^ a[256];
assign dout[1]  = a[176] ^ a[81];
assign dout[2]  = a[136] ^ a[121];
assign dout[3]  = a[35]  ^ a[222];
assign dout[4]  = a[249] ^ a[8];
assign dout[5]  = a[134] ^ a[123];
assign dout[6]  = a[197] ^ a[60];
assign dout[7]  = a[234] ^ a[23];
assign dout[8]  = a[64]  ^ a[193];
assign dout[9]  = a[213] ^ a[44];
assign dout[10] = a[223] ^ a[34];
assign dout[11] = a[184] ^ a[73];
assign dout[12] = a[2]   ^ a[255];
assign dout[13] = a[95]  ^ a[162];
assign dout[14] = a[15]  ^ a[242];
assign dout[15] = a[70]  ^ a[187];
assign dout[16] = a[241] ^ a[16];
assign dout[17] = a[11]  ^ a[246];
assign dout[18] = a[137] ^ a[120];
assign dout[19] = a[211] ^ a[46];
assign dout[20] = a[128] ^ a[129];
assign dout[21] = a[169] ^ a[88];
assign dout[22] = a[189] ^ a[68];
assign dout[23] = a[111] ^ a[146];
assign dout[24] = a[4]   ^ a[253];
assign dout[25] = a[190] ^ a[67];
assign dout[26] = a[30]  ^ a[227];
assign dout[27] = a[140] ^ a[117];
assign dout[28] = a[225] ^ a[32];
assign dout[29] = a[22]  ^ a[235];
assign dout[30] = a[17]  ^ a[240];
assign dout[31] = a[165] ^ a[92];

endmodule