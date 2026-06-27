import os
from PIL import Image
from rembg import remove

def process_image(input_path, output_path):
    print(f"Processing {input_path}...")
    try:
        with open(input_path, 'rb') as i:
            with open(output_path, 'wb') as o:
                o.write(remove(i.read()))
        print(f"Saved {output_path}")
    except Exception as e:
        print(f"Error: {e}")

media_dir = '/home/denis/.gemini/antigravity/brain/d17cd54b-394f-4a24-8de9-652bafc3fce5/'
output_dir = 'media/quirofano/'

for file in os.listdir(media_dir):
    if file.startswith('gasa_') and file.endswith('.png'):
        process_image(os.path.join(media_dir, file), os.path.join(output_dir, 'gasa.png'))
    elif file.startswith('paciente_') and '_new_' in file and file.endswith('.png'):
        num = file.split('_')[1]
        process_image(os.path.join(media_dir, file), os.path.join(output_dir, f'paciente_{num}.png'))
