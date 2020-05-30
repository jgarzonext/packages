--------------------------------------------------------
--  DDL for Package PAC_MD_TR234_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_TR234_OUT" AS
/******************************************************************************
   NOMBRE:       pac_md_tr234_out
   PROPÓSITO:    Package para llamadas desde JAVA a funciones del paquete PK_TR234_OUT (envio ficheros norma 234)

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/01/2010   JGM                1. Creación del package. Bug 13503
******************************************************************************/

   /*************************************************************************
         Función que sirve para generar el fichero MAP de norm 234
           1.    PCINOUT: Tipo numérico. Parámetro de entrada. Nos dice si es traspaso de Entrada (1) o Salida (2)
           2.    PFHASTA: Tipo Fecha. Parámetro de entrada. Hasta que fecha hacemos el fichero de traspasos
           3.    PTNOMFICH: Tipo String. Parámetro de salida. Nombre del fichero resultado
           4.    MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
           5.    PNFICHERO: Tipo NUMBER (opcional) indica que numero de orden de fichero (0-9) queremos generar
   *************************************************************************/
   FUNCTION f_generar_fichero(
      pcinout IN NUMBER,
      pfhasta IN DATE,
      ptnomfich IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pnfichero IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
         Función que sirve para buscar los traspasos que se incluiran en el fichero
           1.    PCINOUT: Tipo numérico. Parámetro de entrada. Nos dice si es traspaso de Entrada (1) o Salida (2)
           2.    PFHASTA: Tipo Fecha. Parámetro de entrada. Hasta que fecha hacemos el fichero de traspasos
           3.    MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   *************************************************************************/
   FUNCTION f_buscar_traspasos(
      pcinout IN NUMBER,
      pfhasta IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_traspasos;
END pac_md_tr234_out;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TR234_OUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TR234_OUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TR234_OUT" TO "PROGRAMADORESCSI";
