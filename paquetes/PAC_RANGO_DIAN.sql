CREATE OR REPLACE PACKAGE "PAC_RANGO_DIAN" AS
  /******************************************************************************
  NOMBRE:      PAC_RANGO_DIAN
  PROPÓSITO:   Package de rango dian

  REVISIONES:
  Ver        Fecha        Autor             Descripción
  ---------  ----------  ---------------  ------------------------------------
  1.0        --/--/----   ---                1. Creación del package.
  2.0        19/06/2019   JLTS               3. Se incluye esta columna SPRODUC en f_set_versionesdian
*/
  /**************************************************************************/

  /*************************************************************************
  Recupera Versiones Dian

  *************************************************************************/
  FUNCTION f_get_versionesdian(psrdian     IN NUMBER,
                               presolucion IN NUMBER,
                               psucursal   IN NUMBER,
                               pcgrupo     IN VARCHAR2,
                               pdescrip    IN VARCHAR2,
                               pusuario    IN VARCHAR2,
                               pmail       IN NUMBER,
                               pcactivi    IN NUMBER,
                               pcramo      IN NUMBER,
                               ptestado    IN NUMBER,
                               mensajes    OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

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
                               mensajes   OUT t_iax_mensajes) RETURN NUMBER;

  FUNCTION f_get_gruposdian RETURN VARCHAR2;

 /* FUNCTION f_generar_certificado(psseguro IN NUMBER,
                                 pnmovimi IN NUMBER,
                                 pcagente IN NUMBER,
                                 pcgrupo  IN VARCHAR2,
                                 pcactivi IN NUMBER) RETURN NUMBER;*/

  FUNCTION f_asigna_rangodian(
        psseguro IN NUMBER,
        pmovimi IN NUMBER
    )   RETURN NUMBER;
END PAC_RANGO_DIAN;
/
