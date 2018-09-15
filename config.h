#ifndef __CONFIG_H
#define __CONFIG_H

/* Include files */
#define HAVE_FCNTL_H
#define HAVE_UNISTD_H
#define HAVE_STDINT_H
/* #undef HAVE_STDBOOL_H */
#define HAVE_INTTYPES_H
/* #undef HAVE_SYS_MODEM_H */
#define HAVE_SYS_FILIO_H
/* #undef HAVE_SYS_SELECT_H */
/* #undef HAVE_SYS_SOCKIO_H */
/* #undef HAVE_SYS_STRTIO_H */
/* #undef HAVE_EVENTFD_H */
/* #undef HAVE_TIMERFD_H */
#define HAVE_TM_GMTOFF
/* #undef HAVE_AIO_H */
/* #undef HAVE_POLL_H */
/* #undef HAVE_SYSLOG_H */
/* #undef HAVE_JOURNALD_H */
/* #undef HAVE_PTHREAD_MUTEX_TIMEDLOCK */
/* #undef HAVE_VALGRIND_MEMCHECK_H */
/* #undef HAVE_EXECINFO_H */

/* Features */
/* #undef HAVE_ALIGNED_REQUIRED */

/* Options */
/* #undef WITH_PROFILER */
/* #undef WITH_GPROF */
/* #undef WITH_SSE2 */
#define WITH_NEON
/* #undef WITH_IPP */
/* #undef WITH_NATIVE_SSPI */
/* #undef WITH_JPEG */
/* #undef WITH_WIN8 */
/* #undef WITH_RDPSND_DSOUND */
/* #undef WITH_EVENTFD_READ_WRITE */
/* #undef HAVE_MATH_C99_LONG_DOUBLE */

/* #undef WITH_FFMPEG */
/* #undef WITH_GSTREAMER_1_0 */
/* #undef WITH_GSTREAMER_0_10 */
/* #undef WITH_WINMM */
/* #undef WITH_MACAUDIO */
/* #undef WITH_OSS */
/* #undef WITH_ALSA */
/* #undef WITH_PULSE */
/* #undef WITH_IOSAUDIO */
/* #undef WITH_OPENSLES */
/* #undef WITH_GSM */
/* #undef WITH_MEDIA_FOUNDATION */

/* Plugins */
#define STATIC_CHANNELS
/* #undef WITH_RDPDR */


/* Debug */
/* #undef WITH_DEBUG_CERTIFICATE */
/* #undef WITH_DEBUG_CAPABILITIES */
/* #undef WITH_DEBUG_CHANNELS */
/* #undef WITH_DEBUG_CLIPRDR */
/* #undef WITH_DEBUG_DVC */
/* #undef WITH_DEBUG_TSMF */
/* #undef WITH_DEBUG_GDI */
/* #undef WITH_DEBUG_KBD */
/* #undef WITH_DEBUG_LICENSE */
/* #undef WITH_DEBUG_NEGO */
/* #undef WITH_DEBUG_NLA */
/* #undef WITH_DEBUG_NTLM */
/* #undef WITH_DEBUG_TSG */
/* #undef WITH_DEBUG_ORDERS */
/* #undef WITH_DEBUG_RAIL */
/* #undef WITH_DEBUG_RDP */
/* #undef WITH_DEBUG_REDIR */
/* #undef WITH_DEBUG_RFX */
/* #undef WITH_DEBUG_SCARD */
/* #undef WITH_DEBUG_SND */
/* #undef WITH_DEBUG_SVC */
/* #undef WITH_DEBUG_RDPEI */
/* #undef WITH_DEBUG_TIMEZONE */
/* #undef WITH_DEBUG_THREADS */
/* #undef WITH_DEBUG_MUTEX */
/* #undef WITH_DEBUG_TRANSPORT */
/* #undef WITH_DEBUG_WND */
/* #undef WITH_DEBUG_X11 */
/* #undef WITH_DEBUG_X11_CLIPRDR */
/* #undef WITH_DEBUG_X11_LOCAL_MOVESIZE */
/* #undef WITH_DEBUG_XV */
/* #undef WITH_DEBUG_ANDROID_JNI */
/* #undef WITH_DEBUG_RINGBUFFER */
#endif
