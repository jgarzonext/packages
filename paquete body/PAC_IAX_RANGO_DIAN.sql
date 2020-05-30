CREATE OR REPLACE PACKAGE BODY pac_iax_rango_dian IS

  /******************************************************************************
     NOMBRE:     pac_iax_rango_dian
     PROPÓSITO:  Funciones rango dian

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        26/08/2016   FOR               1. Creación del package.
     2.0        19/06/2019   JLTS              2. Se incluye esta columna SPRODUC en f_set_versionesdian
  ******************************************************************************/

  /*************************************************************************
  Recupera Versiones Dian

  *************************************************************************/
  FUNCTION f_get_versionesdian(psrdian     IN NUMBER,
                               presolucion IN NUMBER,
                               pdescrip    IN VARCHAR2,
                               pcramo      IN NUMBER,
                               pcactivi    IN NUMBER,

                               pcgrupo   IN VARCHAR2,
                               psucursal IN NUMBER,
                               pusuario  IN VARCHAR2,
                               pmail     IN NUMBER,
                               ptestado  IN NUMBER,

                               mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
    vpasexec    NUMBER;
    vnumerr     NUMBER;
    vparam      VARCHAR2(1000);
    vobjectname VARCHAR2(200) := 'pac_iax_rango_dian.f_get_versionesdian';
    cur         SYS_REFCURSOR;
  BEGIN
    vpasexec := 1;

    cur := pac_md_rango_dian.f_get_versionesdian(psrdian,
                                                 presolucion,
                                                 psucursal,
                                                 pcgrupo,
                                                 pdescrip,
                                                 pusuario,
                                                 pmail,
                                                 pcactivi,
                                                 pcramo,
                                                 ptestado,
                                                 mensajes);

    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN NULL;
  END f_get_versionesdian;

  FUNCTION f_set_versionesdian(psrdian    IN NUMBER,
                               pnresol    IN NUMBER,
                               pcagente   IN NUMBER,
                               pcgrupo    IN VARCHAR2,
                               pfresol    IN DATE,
                               pfinivig   IN DATE,
                               pffinvig   IN DATE,
                               ptdescrip  IN VARCHAR2,
                               pninicial  IN NUMBER,
                               pnfinal    IN NUMBER,
                               pcusu      IN VARCHAR2,
                               ptestado   IN VARCHAR2,
                               pcenvcorr  IN VARCHAR2,
                               pnaviso    IN NUMBER,
                               pncertavi  IN NUMBER,
                               pncontador IN NUMBER,
                               pmodo      IN VARCHAR2,
                               pcactivi   IN NUMBER,
                               pcramo     IN NUMBER,
                               psproduc   IN NUMBER, --IAXIS-3288 -JLTS -19/06/2019. Se incluye esta columna

                               mensajes OUT t_iax_mensajes) RETURN NUMBER IS
    vpasexec    NUMBER;
    vnumerr     NUMBER;
    vparam      VARCHAR2(1000);
    vobjectname VARCHAR2(200) := 'pac_iax_rango_dian.f_set_versionesdian';

  BEGIN
    vpasexec := 1;

    RETURN pac_md_rango_dian.f_set_versionesdian(psrdian,
                                                 pnresol,
                                                 pcagente,
                                                 pcgrupo,
                                                 pfresol,
                                                 pfinivig,
                                                 pffinvig,
                                                 ptdescrip,
                                                 pninicial,
                                                 pnfinal,
                                                 pcusu,
                                                 ptestado,
                                                 pcenvcorr,
                                                 pnaviso,
                                                 pncertavi,
                                                 pncontador,
                                                 pmodo,
                                                 pcactivi,
                                                 pcramo,
                                                 psproduc, --IAXIS-3288 -JLTS -19/06/2019. Se incluye esta columna
                                                 mensajes);
  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

      RETURN 1;
  END f_set_versionesdian;

  FUNCTION f_get_gruposdian(mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
    vpasexec    NUMBER;
    vnumerr     NUMBER;
    vparam      VARCHAR2(1000);
    vobjectname VARCHAR2(200) := 'pac_iax_rango_dian.f_get_gruposdian';
    cur         SYS_REFCURSOR;
  BEGIN
    vpasexec := 1;

    cur := pac_md_rango_dian.f_get_gruposdian(mensajes);

    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN NULL;
  END f_get_gruposdian;
END pac_iax_rango_dian;
/
