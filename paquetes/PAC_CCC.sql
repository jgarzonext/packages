--------------------------------------------------------
--  DDL for Package PAC_CCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CCC" AS
/******************************************************************************
   NOMBRE:       PAC_CCC
   PROPÓSITO:  Funciones para realizar la validación de las cuentas bancarias

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/05/2010   AVT             Creación del package.
   2.0        27/10/2011   JGR             0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito
   3.0        14/01/2012   JMF             0020761 LCOL_A001- Quotes targetes
******************************************************************************/
/**************************************************************************
    F_CCC        Valida una cuenta bancaria y devuelve como parámetros
            el número incluyendo los dígitos de control.
            Devuelve como valor el código del error. 0 si está bien.
    ALLIBMFM
    f_ccc pasa a ser f_ccc_esp validación de cuentas españolas
    está función será llamada por f_ccc.
**************************************************************************/
   FUNCTION f_ccc_esp(pncuenta IN NUMBER, pncontrol IN OUT NUMBER, pnsalida IN OUT NUMBER)
      RETURN NUMBER;

/***********************************************************************
    02/2007  MCA
    F_VALIDA_IBAN: Valida el código IBAN entrado por parámetro
    Devuelve 1 si es correcto.

    JFD 27/09/2007 para igualar salida de datos con f_ccc si no hay error
    devuelve 0 en caso contrario devuelve un literal.

    JFD 08/10/2007  Mofificamos la función para que valide la procedencia
    del código y la longitud.
***********************************************************************/
   FUNCTION f_valida_iban(pcodigo IN VARCHAR2)
      RETURN NUMBER;

/**************************************************************************
    F_CCC        Valida una cuenta bancaria y devuelve como parámetros
            el número incluyendo los dígitos de control.
            Devuelve como valor el código del error. 0 si está bien.
    ALLIBMFM
            - adaptación cuentas bancarias andorra
                - Se elimina parámetro dígito de control y su fórmula
                - Se valida formato exclusivo de cada banco
                - Los parámetros de cuenta se cambia por varchar2
                  ya que una entidad incluye letras en la cuenta

                    BANCO MASCTA        LONGITUD
                --------- -------------------
                        1 BB001ZZZZZZ        11
                        2 BBXXXXYYZZZZZZZAA    17
                        3 BB00ZZZZZZ        10
                        3 BB00ZZZZZL        10
                        3 BB00ZZZZLL        10
                        4 BBXXZZZZZZAAA        13
                        5 BB
                        6 BB11ZZZZZZZZ        12
                        6 BB12ZZZZZZZZ        12
                        7 BBXXZZZZZZAAA        13
                        8 BBXXXYYZZZZZZZZ    15

                CPARAME = FORMATBANC
                ------------------------------
                X=Oficina,
                Y=Tipo cta,
                Z=Número cta(num),
                A=Cód.interno(Alfanum),
                L=Letra, (hasta dos letras)
                Otros valores=Valor fijo(hasta 3 valores fijos)

   JFD - 28/09/2007 - Se renombra la función f_ccc de Global Risk por f_ccc_and
**************************************************************************/
   FUNCTION f_ccc_and(pncuenta IN VARCHAR2, pnsalida IN OUT VARCHAR2)
      RETURN NUMBER;

/**************************************************************************
    F_CCC        Valida la cuenta bancaria Belga

**************************************************************************/
   FUNCTION f_ccc_bel(pncuenta IN VARCHAR2, pnsalida IN OUT VARCHAR2)
      RETURN NUMBER;

/**************************************************************************
   F_CCC    Valida una cuenta bancaria y devuelve como parametros
         el numero incluyendo los digitos de control.
         Devuelve como valor el codigo del error. 0 si esta bien.

   14502 12-05-2010 AVT - adaptación cuentas bancarias Angola basada en la
                          f_ccc de Asphales
**************************************************************************/
   FUNCTION f_ccc_ang(pncuenta IN VARCHAR2, pnsalida IN OUT VARCHAR2)
      RETURN NUMBER;

/**************************************************************************
    F_CCC_COL_BCO  Valida una cuenta bancaria Colombiana y devuelve como parámetros el número

    2.0  27/10/2011  JGR  2. 0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito

    Devuelve como valor el código del error. 0 si está bien.
**************************************************************************/
   FUNCTION f_ccc_col_bco(pctipban IN VARCHAR2, pncuenta IN VARCHAR2, pnsalida IN OUT VARCHAR2)
      RETURN NUMBER;

/**************************************************************************
    F_CCC_COL_BCO  Valida una cuenta bancaria Colombiana y devuelve como parámetros el número

    2.0  27/10/2011  JGR  2. 0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito

    Devuelve como valor el código del error. 0 si está bien.
**************************************************************************/
   FUNCTION f_ccc_col_tar(pctipban IN VARCHAR2, pncuenta IN VARCHAR2, pnsalida IN OUT VARCHAR2)
      RETURN NUMBER;

/**************************************************************************
    f_esTarjeta  Nos dice si el tipo de cuenta es tarjeta de credito o no.
    Devuelve como valor 1=Tarjeta o 0=Cuenta o resto de casos.
-- BUG 0020761 - 14/01/2012 - JMF
**************************************************************************/
   FUNCTION f_estarjeta(p_ctipcc IN NUMBER, p_ctipban IN NUMBER)
      RETURN NUMBER;
END pac_ccc;

/

  GRANT EXECUTE ON "AXIS"."PAC_CCC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CCC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CCC" TO "PROGRAMADORESCSI";
