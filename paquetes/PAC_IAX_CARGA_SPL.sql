--------------------------------------------------------
--  DDL for Package PAC_IAX_CARGA_SPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CARGA_SPL" AUTHID CURRENT_USER AS
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
      pcdarchi IN int_carga_archivo_spl.cdarchi%TYPE,
      pcarcest IN int_carga_archivo_spl.carcest%TYPE,
      pctiparc IN int_carga_archivo_spl.ctiparc%TYPE,
      pcsepara IN int_carga_archivo_spl.csepara%TYPE,
      pdsproces IN cfg_files.cproceso%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

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
      pndecimal IN NUMBER DEFAULT NULL,   --RACS
      pcmask IN VARCHAR2 DEFAULT NULL,   --RACS
      pcmodo IN VARCHAR2,
      pcedit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_carga_valida_spl(
      pcdarchi IN VARCHAR2,
      pccampo1 IN VARCHAR2,
      pctipcam1 IN NUMBER,
      pccampo2 IN VARCHAR2,
      pctipcam2 IN NUMBER,
      pcoperador IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_campo_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_valida_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_cabecera_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_del_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_valida_spl(pcdarchi IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_int_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE,
      obccampo OUT ob_iax_cargacampo_spl,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_carga_spl;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_SPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_SPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_SPL" TO "PROGRAMADORESCSI";
