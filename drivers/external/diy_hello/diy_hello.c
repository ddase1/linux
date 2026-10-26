#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("DIY Linux");
MODULE_DESCRIPTION("DIY Linux external driver-disk validation module");
MODULE_VERSION("0.1.1");

static int __init diy_hello_init(void)
{
    pr_info("DIY_DRIVER_LOADED: diy_hello\n");
    return 0;
}

static void __exit diy_hello_exit(void)
{
    pr_info("DIY_DRIVER_UNLOADED: diy_hello\n");
}

module_init(diy_hello_init);
module_exit(diy_hello_exit);
