--------------------------------------------------------
--  DDL for Package PAC_MD_CARGA_SPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_CARGA_SPL" AUTHID CURRENT_USER AS
      /*******************************************************************************
      FUNCION f_mandato_activo
      Descripcion:guardar los datos en la tabla INT_CARGA_ARCHIVO_SPL.
      Parámetros:
         cdarchi: Código del archivo - Obligatorio
         carcest: Estructura del archivo - Obligatorio
         ctiparc: Código para Standing Order = 1; para cheques = 2 - Obligatorio
         sperson: Secuencia única de identificación de una persona - Obligatorio

      Retorna un valor numérico:
      .

   */
   FUNCTION f_set_carga_archivo_spl(
      pcdarchi IN VARCHAR2,
      pcarcest IN NUMBER,
      pctiparc IN NUMBER,
      pcsepara IN VARCHAR2,
      pdsproces IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*******************************************************************************
      FUNCION f_set_campo_spl
      Descripcion:define los campos que contendrán los archivos que se cargan en iAxis
      Parámetros:
         cdarchi:   Código del archivo - Obligatorio
         NORDEN:    Secuencia de orden de los campos
         CCAMPO:    Nombre del campo - Obligatorio
         CTIPCAM:   Tipo de campo ( HEADER 1, CONTENT 2, FOOTER 3) - Obligatorio
         NPOSICI:   Posición dónde se encuentra el campo
         NLONGITUD: Longitud del campo
      Retorna un valor numérico:
      .

   */
   FUNCTION f_set_campo_spl(
      pcdarchi IN VARCHAR2,
      pnorden IN NUMBER,
      pccampo IN VARCHAR2,
      pctipcam IN VARCHAR2,
      pnordennew IN NUMBER,
      pccamponew IN VARCHAR2,
      pctipcamnew IN VARCHAR2,
      pnposici IN NUMBER,
      pnlongitud IN NUMBER,
      pntipo IN NUMBER,
      pndecimal IN NUMBER,   --RACS
      pcmask IN VARCHAR2,   --RACS
      pcmodo IN VARCHAR2,
      pcedit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_carga_valida_spl(
      pcdarchi IN VARCHAR2,
      pccampo1 IN VARCHAR2,
      pctipcam1 IN NUMBER,
      pccampo2 IN VARCHAR2,
      pctipcam2 IN NUMBER,
      pcoperador IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_campo_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_valida_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

       /*******************************************************************************
      FUNCION f_del_campo_spl
      Descripcion: Encargada de borrar los registros de la tabla int_carga_campo_spl.
      Parámetros:
         cdarchi:   Código del archivo - Obligatorio
         norden:    Secuencia de orden de los campos
         ccampo:    Nombre del campo - Obligatorio
         ctipcam:   Tipo de campo ( HEADER 1, CONTENT 2, FOOTER 3) - Obligatorio
         nposici:   Posición dónde se encuentra el campo
         nlongitud: Longitud del campo
       sperson:   Secuencia única de identificación de una persona - Obligatorio
      Retorna un valor numérico:
      .
   */
   FUNCTION f_get_cabecera_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_del_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*******************************************************************************
      FUNCION f_del_valida_spl
      Descripcion: Encargada de borrar un registro de la tabla int_carga_valida_spl.
      Parámetros:
         cdarchi:   Código del archivo - Obligatorio
         ccampo1:   Campo 1 (tendrá que ser del tipo header o footer)
        ctipcam1:  Tipo de campo ( HEADER 1 o FOOTER 3)
       ccampo2:   Campo 2(tendrá que ser del tipo content)
       ctipcam2:  Tipo de campo ( CONTENT 2)
      Retorna un valor numérico:
      .
   */
   FUNCTION f_del_valida_spl(pcdarchi IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_int_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE,
      obccampo OUT ob_iax_cargacampo_spl,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_carga_spl;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_SPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_SPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_SPL" TO "PROGRAMADORESCSI";
