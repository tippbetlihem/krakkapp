import cv2
import numpy as np
import os

# Slóð að upprunalegu myndinni
input_path = "characters.png"
output_dir = "chars_out"
os.makedirs(output_dir, exist_ok=True)

# Les mynd (með alpha ef til, annars BGR)
img = cv2.imread(input_path, cv2.IMREAD_UNCHANGED)

# Ef myndin er BGR (3 channel), breytum í RGBA
if img.shape[2] == 3:
    bgr = img
    alpha = np.full(bgr.shape[:2], 255, dtype=np.uint8)
    img = np.dstack([bgr, alpha])

# Aðskiljum rásir
b, g, r, a = cv2.split(img)

# Búum til “foreground mask” – hér er einföld nálgun:
# 1) Breytum í HSV til að greina litríka hluta
bgr = cv2.merge([b, g, r])
hsv = cv2.cvtColor(bgr, cv2.COLOR_BGR2HSV)

# Þú getur fínstillt þessi threshold gildi eftir myndinni
# Hér erum við að reyna að ná litríku hlutunum (karakterunum)
lower = np.array([0, 30, 40])   # H, S, V
upper = np.array([179, 255, 255])
mask = cv2.inRange(hsv, lower, upper)

# Hreinsum maskann aðeins (morphology)
kernel = np.ones((5, 5), np.uint8)
mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

# Finna contours (útlínur) fyrir hvern karakter
contours, hierarchy = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

print(f"Fann {len(contours)} karaktera")

for i, cnt in enumerate(contours):
    x, y, w, h = cv2.boundingRect(cnt)

    # Skera út svæðið
    char_rgba = img[y:y+h, x:x+w].copy()

    # Búa til nýjan alpha út frá maskanum (til að hafa gegnsæjan bakgrunn)
    char_mask = mask[y:y+h, x:x+w]
    # Þar sem maskinn er 0 => bakgrunnur, 255 => karakter
    # Notum þetta sem alpha
    new_alpha = char_mask

    # Tryggjum að alpha sé 8-bit
    new_alpha = cv2.normalize(new_alpha, None, 0, 255, cv2.NORM_MINMAX)
    # Setjum alpha inn í myndina
    b_c, g_c, r_c, _ = cv2.split(char_rgba)
    char_rgba = cv2.merge([b_c, g_c, r_c, new_alpha])

    out_path = os.path.join(output_dir, f"char_{i+1}.png")
    cv2.imwrite(out_path, char_rgba)

    print(f"Vistaði {out_path}")
