#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    int in = open("/dev/hidraw9", O_RDONLY);
    int out = open("/dev/hidg0", O_WRONLY);

    unsigned char buf[64];

    while (1) {
        int n = read(in, buf, sizeof(buf));
        if (n > 0) {
            write(out, buf, n);
        }
    }
}
