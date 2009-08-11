/* public domain rewrite of finite(3) */
#ifdef TARGET_CPU_ARM
int
finite(double n)
{
    return !isnan(n) && !isinf(n);
}
#endif
