--------------------------------------------------------
--  DDL for Package PAC_REHABILITA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REHABILITA" IS
/******************************************************************************
     NOMBRE:       PAC_REHABILITA
     PROP¿SITO:  Package para gestionar las rehabilitaciones de p¿lizas.

     REVISIONES:
     Ver        Fecha        Autor             Descripci¿n
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/05/2009   ICV               1. Adaptaci¿n para IAX Bug.: 9784
     2.0        12/01/2010   DRA               2. 0010093: CRE - Afegir filtre per RAM en els cercadors
     3.0        23/02/2010   LCF               3. 0009605: BUSCADORS - Afegir matricula,cpostal,desc
     4.0        25/08/2011   JMF               4. 0019274 LCOL_T001 - Rehabilitaciones control l¿mite tiempo desde que se anul¿ la p¿liza
 ******************************************************************************/

   -- MSR 5/6/2007
   -- Creaci¿ del package
   -- Constants a utilitzar

   -- Codi de par¿mtres per si ¿s una anul¿laci¿ efecte.
   motmov_anul_efecto CONSTANT VARCHAR2(20) := 'ANUL_EFECTO';

   -- Antiga funci¿ F_REC_REHAB inclosa dins el package i renombrada com F_RECIBOS
   FUNCTION f_recibos(psseguro IN NUMBER, pnmovimi IN NUMBER, pnrecibo OUT NUMBER)
      RETURN NUMBER;

  -- Antiga funci¿ F_REHABILITA inclosa dins el package
/*************************************************************************
    REHABILITA        Rehabilita una p¿liza
                Devuelve 0 si todo va bien y 1 sino
**************************************************************************/
   FUNCTION f_rehabilita(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pcagente IN NUMBER,
      pnmovimi OUT NUMBER)
      RETURN NUMBER;

   -- F_PREGUNTA
   -- Torna :
   --        0 si no cal fer cap pregunta abans de procedir a la rehabilitaci¿
   --        1 si s'ha de preguntar : S'han trobat extorns en estat pendent. Voleu anul¿lar ?
   --        2 si s'ha de preguntar : S'han trobat extorns en estat cobrat. Voleu descobrar i anul¿lar ?
   FUNCTION f_pregunta(psseguro IN NUMBER)
      RETURN NUMBER;

   -- F_REASEGURO
   -- Torna :
   --        0 si tot OK
   --        altrament torna el n¿mero d'error
   --        p_error te el codi de l'error.
   --  NOTA :  La funci¿ pot tornar 0 + codi error :  No ¿s un error, per¿ s'ha de mostrar aquesta av¿s a l'usuari
   -- Bug 0019274 - 25/08/2011 - JMF: parametres
   FUNCTION f_reaseguro(psseguro IN NUMBER, p_error OUT NUMBER)
      RETURN NUMBER;

   -- F_EJECUTA
   --   Torna 0 si tot OK, altrament torna el codi d'error i la descripci¿ a p_error_desc
   --
   --  Par¿metres entrada:
   --    psseguro :
   --    pcagente :     Si es NULL s'utilitza el codi actual de la taula Seguros
   --    pcmotmov :
   --    panula_extorno :   1 si usuari ha confirmat l'anul¿laci¿ . 0 si no.
   --  Par¿metres sortida:
   --    pxnrecibo :    Nombre rebuts generats
   -- Bug 0019274 - 25/08/2011 - JMF: parametres
   -- Bug 26151 - APD - 26/02/2013 - se a¿ade el parametro ptratar_recibo que indicara si no se debe
   -- realizar nada con los recibos (0) o seguir realizando lo que se hace hasta ahora con los recibos (1)
   FUNCTION f_ejecuta(
      psseguro IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER,
      panula_extorno IN NUMBER,   -- 1 si usuari ha confirmat l'anul¿laci¿
      pxnrecibo OUT NUMBER,
      ptratar_recibo IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION F_GET_polizasanul
        Funci¿n que recuperar¿ p¿lizas anuladas y vencidas dependiendo de los par¿metros de entrada.
        param in Psproduc: Number. C¿digo de producto.
        param in Pnpoliza: Number. n¿ de p¿liza.
        param in Pncertif: Number. n¿ de certificado.
        param in Pnnumide: Varchar2. NIF/CIF del tomador/asegurado
        param in Pbuscar: VARCHAR2.  nombre del tomador/asegurado.
        param in Psnip: VARCHAR2.  c¿digo terceros del tomador/asegurado
        param in Ptipopersona: Number.  Determina si b¿squeda por tomador o asegurado
        param in Pidioma: Number.  idioma
        param in pcagente IN NUMBER,     -- BUG10093:DRA:12/01/2010
        param in pcramo IN NUMBER,       -- BUG10093:DRA:12/01/2010
        param out Psquery: varchar2.  consulta a realizar construida en funci¿n de los par¿metros
        return             : Devolver¿ un number con el error producido.
                             0 en caso de que haya ido correctamente.

        -- BUG 9784 - 11/05/2009 - ICV - Adaptaci¿n para IAX Bug.: 9784
   *************************************************************************/
   FUNCTION f_get_polizasanul(
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnnumide IN VARCHAR2,
      pbuscar IN VARCHAR2,
      psnip IN VARCHAR2,
      ptipopersona IN NUMBER,
      pidioma IN NUMBER,
      pcmatric IN VARCHAR2,   -- BUG9605:LCF:23/02/2010
      pcpostal IN VARCHAR2,   -- BUG9605:LCF:23/02/2010
      ptdomici IN VARCHAR2,   -- BUG9605:LCF:23/02/2010
      ptnatrie IN VARCHAR2,   -- BUG9605:LCF:23/02/2010
      pcagente IN NUMBER,   -- BUG10093:DRA:12/01/2010
      pcramo IN NUMBER,   -- BUG10093:DRA:12/01/2010
      pcpolcia IN VARCHAR2,
      pccompani IN NUMBER,
      pcactivi IN NUMBER,
      pcempres IN NUMBER,
      pcagente_cxt IN NUMBER,
      pfilage IN NUMBER,
      psquery OUT VARCHAR2,
      pcsucursal IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcadm IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcmotor IN VARCHAR2 DEFAULT NULL,   -- BUG25177/132998:JLTS:18/12/2012
      pcchasis IN VARCHAR2 DEFAULT NULL,   -- BUG25177/132998:JLTS:18/12/2012
      pnbastid IN VARCHAR2 DEFAULT NULL   -- BUG25177/132998:JLTS:18/12/2012
                                       )
      RETURN NUMBER;

    /*************************************************************************
        FUNCTION F_get_fsuplem
        Funci¿n que recuperar¿ la fecha de efecto del ¿ltimo suplemento realizado a la p¿liza.
        param in Psseguro: Number. Identificador del Seguro.
        return             : Date en caso correcto
                             Nulo en caso incorrecto

        -- BUG 9784 - 11/05/2009 - ICV - Adaptaci¿n para IAX Bug.: 9784
   *************************************************************************/
   FUNCTION f_get_fsuplem(psseguro IN NUMBER)
      RETURN DATE;

   /*************************************************************************
        FUNCTION F_get_motanul
        Funci¿n que recuperar¿ la descripci¿n del motivo de anulaci¿n de la p¿liza.
        param in Psseguro: Number. Identificador del Seguro.
        return             : Devuelve un varchar con el motivo de anulaci¿n en caso correcto
                             Nulo en caso incorrecto

        -- BUG 9784 - 11/05/2009 - ICV - Adaptaci¿n para IAX Bug.: 9784
   *************************************************************************/
   FUNCTION f_get_motanul(psseguro IN NUMBER, pidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
       FUNCTION f_recobra_extorno
       Genera un recibo por el importe de cada uno de los extornos generados en la anulacion
        param in Psseguro: Number.   Identificador del Seguro.
              in Pnmovimi: Number.   Movimiento de rehabilitacion
              in Pcagente: Varchar2. Codigo de Agente
        return           : 0 en caso correcto
                                  error en caso contrario
        BUG 11997 - 01/02/2010 - ASN
   *************************************************************************/
   FUNCTION f_recobra_extorno(psseguro IN NUMBER, pnmovimi IN NUMBER, pcagente IN VARCHAR2)
      RETURN NUMBER;

    -- BUG 19276 Reemplazos jbn
    /*************************************************************************
       FUNCTION   F_VALIDA_REHABILITA
       validaciones necesarias para determinar si una p¿liza anulada se puede rehabilitar
        param in Psseguro: Number.   Identificador del Seguro.
              in Pnmovimi: Number.   Movimiento de rehabilitacion
              in Pcagente: Varchar2. Codigo de Agente
        return           : 0 en caso correcto
                                  error en caso contrario
   *************************************************************************/
   FUNCTION f_valida_rehabilita(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_solrehab(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnriesgo IN NUMBER,
      pfrehab IN DATE,
      ptobserv IN VARCHAR2)
      RETURN NUMBER;

-- fin BUG 19276 Reemplazos jbn

   -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
   FUNCTION f_genrec(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo OUT NUMBER,
      pcero IN NUMBER DEFAULT NULL,
      pcmodo IN NUMBER DEFAULT 0)
      RETURN NUMBER;
-- BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
END pac_rehabilita;

/

  GRANT EXECUTE ON "AXIS"."PAC_REHABILITA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REHABILITA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REHABILITA" TO "PROGRAMADORESCSI";
