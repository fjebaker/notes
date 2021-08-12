# Linux Kernel Modules

<!--BEGIN TOC-->
## Table of Contents
1. [Devices](#devices)
    1. [Dynamic major device number](#dynamic-major-device-number)
    2. [Loading and removing device modules](#loading-and-removing-device-modules)
    3. [Device nodes](#device-nodes)

<!--END TOC-->

## Devices

Devices are either *character* or *block* devices, differentiated by a `c` or `b` before their permissions when listed
```
ls -l /dev/

...
brw-rw---- 1 root disk      1,   5 Jul 18 19:25 ram5
...
crw-rw-r-- 1 root netdev   10, 242 Jul 18 19:25 rfkill
...
crw-rw-rw- 1 root tty       5,   0 Jul 18 19:25 tty
crw--w---- 1 root tty       4,   0 Jul 18 19:25 tty0
crw--w---- 1 root tty       4,   1 Jul 18 19:25 tty1
crw--w---- 1 root tty       4,  10 Jul 18 19:25 tty10
...
```
Character devices have single character IO (serial ports, parallel ports), whereas block devices communicate over entire data blocks and may provide random access data (disk drives, RAM).

Each device has a major and minor number associated with it, where the major number identifies the associated driver. From [Linux Device Drivers](https://www.oreilly.com/library/view/linux-device-drivers/0596000081/ch03s02.html):

> The minor number is used only by the driver specified by the major number; other parts of the kernel don’t use it, and merely pass it along to the driver. It is common for a driver to control several devices (as shown in the listing); the minor number provides a way for the driver to differentiate among them. 

The driver mapping from *driver name* to *major device number* is listed in
```
/proc/devices
```
which typically lists something like
```
Character devices:
  1 mem
  4 /dev/vc/0
  4 tty
  5 /dev/tty
  5 /dev/console
  5 /dev/ptmx
...

Block devices:
  1 ramdisk
  7 loop
  8 sd
...
```

To view the major and minor numbers of a device, we can use `ls`:
```bash
ls -l /dev/loop*

brw-rw---- 1 root disk  7,   0 Jul 18 19:25 /dev/loop0
brw-rw---- 1 root disk  7,   1 Jul 18 19:25 /dev/loop1
brw-rw---- 1 root disk  7,   2 Jul 18 19:25 /dev/loop2
brw-rw---- 1 root disk  7,   3 Jul 18 19:25 /dev/loop3
brw-rw---- 1 root disk  7,   4 Jul 18 19:25 /dev/loop4
brw-rw---- 1 root disk  7,   5 Jul 18 19:25 /dev/loop5
brw-rw---- 1 root disk  7,   6 Jul 18 19:25 /dev/loop6
brw-rw---- 1 root disk  7,   7 Jul 18 19:25 /dev/loop7
```
Here, instead of a file size, we see the major and minor device numbers, separated by a comma. In the above, the major number is 7 and the minor is incremental from 0 to 7.


Registering and deregeristing device number from a kernel module are handled by
```C
static inline int register_chrdev(
    unsigned int major, 
    const char *name, 
    const struct file_operations *fops
)
```
and
```C
static inline void unregister_chrdev(
    unsigned int major, 
    const char *name
)
```
with documentation and definitions found in `/include/linux/fs.h` ([link to source code](https://elixir.bootlin.com/linux/latest/source/include/linux/fs.h#L2830)).

As far as I can tell from the implementation and experimentation, in `unregister_chrdev` the `name` string is never used, and thus is a little redundant (Linux v5.13.2).

### Dynamic major device number
To dynamically allocate a major device number we require a global variable
```C
static dev_t device_number;
```
`dev_t` is a type definition in the kernel headers, which typically resolves to `uint32_t`.

We then call this function defined in `/include/linux/fs.h`:
```C
int alloc_chrdev_region(
    dev_t &device_number, 
    unsigned baseminor, 
    unsigned count,
    const char *name
)
```
Here, `baseminor` is the first of the range of requested minor numbers, with `count` being the number of minor numbers required by our driver. Minor numbers are allocated sequentially.

The function returns `0` if successful, else a negative number error code. The allocated major and first minor number can then be decomposed from the mutated `device_number` parameter
```C
int major = device_number >> 20;
int minor = device_number & 0xfffff;
```

Deregistering the device is achieved in the same way as before with `unregister_chrdev`.


### Loading and removing device modules
As with any kernel module, it may be loaded with
```bash
sudo insmod module.ko
```
and removed with
```bash
sudo rmmod module
```

More "intelligent" loading, along with required unresolved module dependencies, is facilitated by the `modprobe` program, however for simple drivers this is not required. `modprobe` is useful when loading stacked modules, as it loads dependency modules automatically.


### Device nodes
To create a device node after a major device number has been register, we can use `mkdev`:
```bash
sudo mkdev /dev/device_name c MAJOR MINOR
```
where `MAJOR` and `MINOR` are integers (here, the `c` denotes that this is a character device).


To achieve the same in the module code is non-trivial and requires the use of a number of kernel functions and structures.

In order to create a device node, we first require a device `class`, which we can create using a macro with the effective signature
```C
struct class *class_create(
    struct module *owner,
    const char *name
)
```
included from `/include/linux/cdev.h`. After calling this function, the name will appear in `/sys/class/<name>`.

The *module owner* is almost always just `THIS_MODULE`, and the name is the desired device driver name.

A class, as [documented in the kernel code](https://elixir.bootlin.com/linux/latest/source/include/linux/device/class.h#L54), is essentially an abstracted device:
> Classes allow user space to work with devices based on what they do, rather than how they are connected or how they work.

Next, we can create a device and register it in `sysfs` using
```C
struct device *device_create(
    struct class *class, 
    struct device *parent,
    dev_t devt, 
    void *drvdata, 
    const char *fmt, ...
)
```
The device will now appear both in `/sys/devices/virtual/<class name>/<device name>` and in `/dev/<device name>`.

This function also creates a device node using the major and minor numbers passed as `devt`. The `parent` would usually be the parent device under which this new device should be registered, and `drvdata` is data provided for callbacks. In simple cases, `parent` and `drvdata` can both be `NULL`.

To initialize the file operations, we use
```C
void cdev_init(
    struct cdev *cdev, 
    const struct file_operations *fops
)
```
and then register these character device operations to the device number using
```C
int cdev_add(
    struct cdev *p, 
    dev_t dev, 
    unsigned count
)
```
where count is again the number of minor device numbers corresponding to this device.

In practice, a full module implementing dynamic device numbering and device node creation may look like this
```C
#include <linux/module.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>

#define DRIVER_NAME "exampledriver"

MODULE_LICENSE("GPL");
MODULE_AUTHOR("dustpancake");
MODULE_DESCRIPTION("Example dynamic device number and automatic device registering.");

static dev_t device_number;
static struct class *device_class;
static struct device *device_node;
static struct cdev char_device;

static int devopen(struct inode *devfile, struct file *instance) { printk("Opened!"); return 0; }
static int devshut(struct inode *devfile, struct file *instance) { printk("Closed!"); return 0; }

static struct file_operations fops = {
    .owner = THIS_MODULE,
    .open = devopen,
    .release = devshut 
};

static int __init mod_init(void)
{
    if (alloc_chrdev_region(&device_number, 0, 1, DRIVER_NAME) < 0) {
        pr_err("Device number could not be allocated.\n");
        return -1;
    }

    pr_info("Device major %d minor %d registered.\n", device_number >> 20, device_number & 0xfffff);

    device_class = class_create(THIS_MODULE, DRIVER_NAME);
    if (device_class == NULL) {
        pr_err("Device class could not be created. \n");
        goto ClassErr;
    }
    
    device_node = device_create(device_class, NULL, device_number, NULL, DRIVER_NAME);
    if (device_node == NULL) {
        pr_err("Device node could not be created. \n");
        goto FileErr;
    }
    
    cdev_init(&char_device, &fops);

    if (cdev_add(&char_device, device_number, 1) == -1) {
        pr_err("Registering of char device to kernel failed.\n");
        goto AddErr;
    }

    return 0;

AddErr:
    device_destroy(device_class, device_number);
FileErr:
    class_destroy(device_class);
ClassErr:
    unregister_chrdev(device_number, DRIVER_NAME);

    return -1;
}

static void __exit mod_exit(void)
{
    cdev_del(&char_device);
    device_destroy(device_class, device_number);
    class_destroy(device_class);
    unregister_chrdev(device_number, DRIVER_NAME);
}

module_init(mod_init);
module_exit(mod_exit);
```

*Note:* generally the class name and device name should be different. Consider a suite of GPIO device drivers that all function on different LEDS: here the class name could be something descriptive like `leds` and the individual device drivers be `warning`, `error`, `power`, etc.

The `__init` and `__exit` keywords are used to hint to the kernel that these functions are only required when initializing or exiting the module, and that the symbols can be unloaded when not required. These functions are further marked into a global variable with the `module_init` and `module_exit` macros. If a module does not define an exit function, then the kernel does not allow it to be unloaded. 