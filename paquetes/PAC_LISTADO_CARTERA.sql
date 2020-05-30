--------------------------------------------------------
--  DDL for Package PAC_LISTADO_CARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LISTADO_CARTERA" IS
   /******************************************************************************
      NOMBRE:     PAC_LISTADO_CARTERA
      PROPÓSITO:  Funciones para la obtención de listados de cartera
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        04/10/2010   SRA             1. Bug 0016137: Creación del package.
      2.0        23/12/2010   ICV             2. 0016137: CRT003 - Carga fichero cartera -> Listado cartera
      3.0        08/11/2011   APD             3. 0019316: CRT - Adaptar pantalla de comisiones
   ******************************************************************************/

   /*************************************************************************
         f_compara_recibos_poliza                       : dado un número de seguro y una fecha de cartera, recupera datos del recibo correspondiente
                                                     : a ésta cartera y los compara con los del recibo de cartera anterior, obteniendo porcentajes
                                                     : de variación
      psseguro in seguro.sseguro%type                : identificador del seguro en AXIS
      pfechacartera in date                          : fecha que se toma como referencia para la comparación de carteras
      piprinet_ultimo out vdetrecibos.iprianet%type  : prima neta del recibo de cartera con fecha pfechacartera
      piprinet_anterior out vdetrecibos.iprianet%type: prima neta del recibo anterior a la cartera de pfechacartera
      piprinet_variacion out number                  : porcentaje de variación de la prima neta
      picombru_ultimo out vdetrecibos.icombru%type   : comisión bruta del recibo de cartera con fecha pfechacartera
      picombru_anterior out vdetrecibos.icombru%type : comisión bruta del recibo anterior a la cartera de pfechacartera
      picombru_variacion out number)                 : porcentaje de variación de la comisión bruta
      return number                                  : control de errores
   *************************************************************************/
   FUNCTION f_compara_recibos_poliza(
      psseguro IN seguros.sseguro%TYPE,
      pultrec IN recibos.nrecibo%TYPE,
      pefecultrec IN DATE,
      piprinet_ultimo IN NUMBER,
      picombru_ultimo IN NUMBER,
      pnrecibo_anterior OUT recibos.nrecibo%TYPE,
      pfefector_anterior OUT recibos.fefecto%TYPE,
      pfvencimr_anterior OUT recibos.fefecto%TYPE,
      piprinet_anterior OUT vdetrecibos.iprinet%TYPE,
      piprinet_variacion OUT NUMBER,
      picombru_anterior OUT vdetrecibos.icombru%TYPE,
      picombru_variacion OUT NUMBER,
      pcreccia_anterior OUT recibos.creccia%TYPE)
      RETURN NUMBER;

   -- BUG 0016137 - 04/10/2010 - SRA
   /*************************************************************************
         f_listado_polizas_carteras      : función que dada una fecha de cartera devuelve todas aquellas pólizas que
                                        1) estaban vigente en la fecha de renovación de cartera
                                        2) tienen recibos de nueva producción o de renovación en el mes pfechacartera
      pccompani in companipro.ccompani%type: identificador de la compañía que oferta el producto en AXIS
      pfechacartera in date           : fecha que se toma como referencia para la comparación de carteras
      pquery out varchar2             : sentencia dinámica que devuelve el cursor con el listado de pólizas
   *************************************************************************/
   FUNCTION f_listado_carteras(
      pcempres IN seguros.cempres%TYPE,
      pccompani IN companipro.ccompani%TYPE,
      psproduc IN seguros.sproduc%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
         f_listado_polizas_sincartera      : función que dada una fecha de cartera devuelve todas aquellas pólizas que
                                        1) estaban vigente en la fecha de renovación de cartera
                                        2) debían tener recibos de renovación en el mes pfechacartera pero estos no se han encontrado
      pccompani in companipro.ccompani%type: identificador de la compañía que oferta el producto en AXIS
      pfechacartera in date           : fecha que se toma como referencia para la comparación de carteras
      pquery out varchar2             : sentencia dinámica que devuelve el cursor con el listado de pólizas
   *************************************************************************/
   FUNCTION f_listado_polizas_sincartera(
      pcempres IN seguros.cempres%TYPE,
      pccompani IN companipro.ccompani%TYPE,
      psproduc IN seguros.sproduc%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      F_PCOMISI_CORREDURIA
      Funcion para calcular la comision de correduria.
      Es copia de la f_pcomisi a dia 08/11/2011
   ************************************************************************/
   -- Bug 19316 - APD - 08/11/2011 - se crea la funcion
   FUNCTION f_pcomisi_correduria(
      psseguro IN NUMBER,
      pcmodcom IN NUMBER,
      pfretenc IN DATE,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER,
      pcagente IN NUMBER DEFAULT NULL,
      pcramo IN NUMBER DEFAULT NULL,
      pcmodali IN NUMBER DEFAULT NULL,
      pctipseg IN NUMBER DEFAULT NULL,
      pccolect IN NUMBER DEFAULT NULL,
      pcactivi IN NUMBER DEFAULT NULL,
      pcgarant IN NUMBER DEFAULT NULL,
      pttabla IN VARCHAR2 DEFAULT NULL,
      pfuncion IN VARCHAR2 DEFAULT 'CAR',
      pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;
END;
 

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTADO_CARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADO_CARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADO_CARTERA" TO "PROGRAMADORESCSI";
