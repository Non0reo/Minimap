def value_to_rgb(value):
    color = [0, 0, 0]
    color[0] = value
    color[1] = 255 - value
    color[2] = (value + 128) % 256
    return color


for i in range(0, 255):
    color = value_to_rgb(i)
    red = color[0] / 255
    green = color[1] / 255
    blue = color[2] / 255

    # red = color[0]
    # green = color[1]
    # blue = color[2]
    
    print("vec4(",red, ', ', green, ', ', blue, ", 1.0)")