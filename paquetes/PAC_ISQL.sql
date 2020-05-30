--------------------------------------------------------
--  DDL for Package PAC_ISQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ISQL" AS
/****************************************************************************
   NOMBRE:    PAC_ISQL
   PROPÓSITO: Funciones para impresión de rtf's

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ----------------------------------
   2.0        02/03/2009  SBG              1. Modificaciones bug 9289
   3.0        13/05/2009  ICV              2. 0010078: IAX - Adaptación impresiones (plantillas)
   4.0        22/07/2009  MSR              3. 10700. Escriure múltiples pàgines + neteja general
   5.0       14/05/2015   JLQ              9. BUG 0035712 --creacion de funcion pac_isqlfor.f_max_nmovimi.
   6.0        26/05/2015  YDA              6. Bug 0035712 Se crean las funciones p_docs_secondreminder y p_docs_finalnotic
   7.0        13/05/2015  ETM              7. Bug 33632/209101: Se modifica la función f_tratamiento_no_pago para generar la plantilla: 'D-1090-102-01 - CANCELLED
****************************************************************************/-- Creación de la estructura de parámetros.
   TYPE regparam IS RECORD(
      par            VARCHAR2(1000),
      val            VARCHAR2(32000)
   );

   TYPE vparam IS TABLE OF regparam
      INDEX BY BINARY_INTEGER;

   e_param_error  EXCEPTION;

   /*************************************************************************
      FUNCTION f_regparam
      Comodi per inicialitzar el contigut de vparam de manera còmode
   *************************************************************************/
   FUNCTION f_regparam(p_par IN VARCHAR2, p_val IN VARCHAR2)
      RETURN regparam;

   --
   -- Variables protegida.
   --   És utilitzada per PAC_ISQLFOR, però no ha de ser utilitzada
   -- per altres programes perquè no estarà inicialitzada correctament
   --
   rgidioma       NUMBER;

   /*************************************************************************
      FUNCTION GenCon
      Construye el documento rtf a partir de la plantilla, los parámetros que
      se le pasan a la consulta asociada a dicha plantilla, y el nombre del
      fichero de salida.
      param in plantilla : Nombre de la plantilla
      param in pusuario  : Nombre del usuario
      param in registro  : Vector de parámetros (nombre + valor)
      param out codimp   : Número secuencia informe
      param in pestado   : Estado
      param in pncopias  : Número de copias.
      return             : 0 si ok, <>0 si ko

      NOTA:
         Tenir en compte que si tenim 2 paràmetres, per exemple NMOVIMI i NMOVIMI2
         (el primer és una substring del segon), perquè el programa funcioni correctament
         s'ha de posar a la llista del pa`rametre registro abans el llarg que al curt
   *************************************************************************/
   FUNCTION gencon(
      plantilla IN VARCHAR2,
      pusuario VARCHAR2,
      registro IN vparam,
      codimp OUT NUMBER,
      pestado IN NUMBER DEFAULT 1,
      pnomfich IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      MSR Pasen a ser funcions privades que no poden ser cridades externament
      FUNCTION Consultar
      FUNCTION Rtf
   *************************************************************************/

   /*************************************************************************
      FUNCTION JPrevio_GenCon
      Aparentemente, no se utiliza
      param in plantilla : Nombre de la plantilla
      param in pusuario  : Nombre del usuario
      param in registro  : Lista de nombre+valor de param. separados por ';'
      param out codimp   : Número secuencia informe
      param in pestado   : Estado
      return             : 0 si ok, <>0 si ko
   *************************************************************************/
   FUNCTION jprevio_gencon(
      plantilla IN VARCHAR2,
      pusuario VARCHAR2,
      registro IN VARCHAR2,
      codimp OUT NUMBER,
      pestado IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   PROCEDURE p_ins_doc_diferida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      psproces IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pctipo IN NUMBER,
      pemail IN VARCHAR2 DEFAULT NULL,
      psubject IN VARCHAR2 DEFAULT NULL);

   PROCEDURE p_docs_cartera(
      psproces IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL,
      pncertif IN NUMBER DEFAULT NULL,
      pmes IN NUMBER DEFAULT NULL,
      panyo IN NUMBER DEFAULT NULL);

   FUNCTION f_ins_doc(
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2,
      ptfich IN VARCHAR2,
      pctipo IN NUMBER,
      pcdiferido IN NUMBER,
      pccategoria IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      psproces IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      piddocdif IN NUMBER,
      pnorden IN NUMBER)
      RETURN NUMBER;

/*****************************************************************************
Esta funcion recupera aquells documentos configurados para enviarse de forma
diferida. Si el envio ha ido correctamente devuelve 0 en caso contrario 1.
Actualiza el estado del envio  con 2 si se ha enviado correctamente y con
3 si se ha enviado pero ha habido algun tipo de fallo
*****************************************************************************/
   FUNCTION f_envio_documentos
      RETURN NUMBER;

--BUG: 34866/202261
   PROCEDURE p_docs_vencimiento(psproces IN NUMBER, psseguro IN NUMBER);

--BUG: 35712/204306
   PROCEDURE p_docs_vencimiento_add(psproces IN NUMBER, psseguro IN NUMBER);

--BUG: 0035712/0202997 Ozea
   PROCEDURE p_docs_renovacion(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pemail IN VARCHAR2,
      psubject IN VARCHAR2);

   PROCEDURE p_docs_reminder(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pemail IN VARCHAR2 DEFAULT NULL,
      psubject IN VARCHAR2 DEFAULT NULL);

   --Bug: 35712/208490
   PROCEDURE p_docs_secondreminder(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pemail IN VARCHAR2 DEFAULT NULL,
      psubject IN VARCHAR2 DEFAULT NULL);

   PROCEDURE p_docs_finalnotic(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pemail IN VARCHAR2 DEFAULT NULL,
      psubject IN VARCHAR2 DEFAULT NULL);

   --INI  --BUG 33632/209101--13/07/2015--ETM
   PROCEDURE p_docs_cancel_letter(psproces NUMBER, psseguro IN NUMBER);

--FIN  --BUG 33632/209101--13/07/2015--ETM
   PROCEDURE p_docs_vencimiento_letter(psproces IN NUMBER, psseguro IN NUMBER);
END pac_isql;

/

  GRANT EXECUTE ON "AXIS"."PAC_ISQL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ISQL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ISQL" TO "PROGRAMADORESCSI";
