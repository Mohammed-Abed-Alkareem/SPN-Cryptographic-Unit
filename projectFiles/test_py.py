#!/usr/bin/env python3
"""
spn_reference.py – faithful Python port of the SPNReferenceModel class
=====================================================================
Type hex numbers when prompted.  Enter -1 for data_in to quit.
"""
from dataclasses import dataclass

# --------------------------- S-box tables ---------------------------

SBOX = {
    0x0: 0xA, 0x1: 0x5, 0x2: 0x8, 0x3: 0x2,
    0x4: 0x6, 0x5: 0xC, 0x6: 0x4, 0x7: 0x3,
    0x8: 0x1, 0x9: 0x0, 0xA: 0xB, 0xB: 0x9,
    0xC: 0xF, 0xD: 0xD, 0xE: 0x7, 0xF: 0xE,
}
INV_SBOX = {v: k for k, v in SBOX.items()}

# --------------------------- helper fns -----------------------------

def pbox(word16: int) -> int:
    """Swap upper and lower bytes of a 16-bit word."""
    return ((word16 & 0x00FF) << 8) | ((word16 & 0xFF00) >> 8)


def sbox_word(word16: int, box: dict[int, int]) -> int:
    """Apply an S-box (or inverse) to each nibble of a 16-bit word."""
    out = 0
    for shift in range(0, 16, 4):                 # 0,4,8,12
        nibble = (word16 >> shift) & 0xF
        out |= box[nibble] << shift
    return out


# ----------------------- the Python class ---------------------------

@dataclass
class SPNReferenceModel:
    data_in:  int
    key:      int
    mode:     int                    # 0 = encrypt, 1 = decrypt
    data_out: int = 0

    def __post_init__(self):
        self.enc_keys, self.dec_keys = self.compute_keys(self.key)

    # ---- key schedule ----
    @staticmethod
    def compute_keys(secret: int):
        b0 = (secret >> 0)  & 0xFF
        b1 = (secret >> 8)  & 0xFF
        b2 = (secret >> 16) & 0xFF
        b3 = (secret >> 24) & 0xFF

        # order matches {byte_high, byte_low}
        k0 = (b0 << 8) | b2            # {b0,b2}
        k1 = (b1 << 8) | b0            # {b1,b0} == secret[15:0]
        k2 = (b0 << 8) | b3            # {b0,b3}

        enc = [k0, k1, k2]
        dec = enc[::-1]                # reverse list
        return enc, dec

    # ---- round primitives ----
    @staticmethod
    def round_encrypt(data: int, key: int) -> int:
        data ^= key
        data = sbox_word(data, SBOX)
        return pbox(data)

    @staticmethod
    def round_decrypt(data: int, key: int) -> int:
        data  = pbox(data)
        data  = sbox_word(data, INV_SBOX)
        return data ^ key

    # ---- top-level wrapper (predict/process) ----
    def predict(self) -> int:
        d = self.data_in & 0xFFFF
        if self.mode == 0:             # encryption
            for k in self.enc_keys:
                d = self.round_encrypt(d, k)
        else:                          # decryption
            for k in self.dec_keys:
                d = self.round_decrypt(d, k)
        self.data_out = d & 0xFFFF
        print(f"[predict] in=0x{self.data_in:04X}  key=0x{self.key:08X} "
              f"mode={self.mode}  -> out=0x{self.data_out:04X}")
        return self.data_out

    # exact alternate signature used in SV code
    @classmethod
    def process(cls, input_data: int, key: int, mode: int) -> int:
        return cls(input_data, key, mode).predict()


# --------------------------- CLI driver -----------------------------

def read_hex(bits: int, prompt: str) -> int:
    while True:
        txt = input(prompt).strip()
        if txt == "-1":
            return -1
        try:
            val = int(txt, 16)
            if val.bit_length() <= bits:
                return val
        except ValueError:
            pass
        print(f"❗ Enter a valid {bits}-bit hex value (e.g. 0x1234).")


def main() -> None:
    print("=== SPN reference emulator ===")
    while True:
        data_in = read_hex(16, "data_in  (16-bit hex, -1 to quit): ")
        if data_in == -1:
            break
        key     = read_hex(32, "key      (32-bit hex): ")
        mode    = input("mode (0 = encrypt, 1 = decrypt): ").strip()
        if mode not in ("0", "1"):
            print("❗ Mode must be 0 or 1\n")
            continue

        out = SPNReferenceModel.process(data_in, key, int(mode))
        print(f"data_out = 0x{out:04X}\n")


if __name__ == "__main__":
    main()
