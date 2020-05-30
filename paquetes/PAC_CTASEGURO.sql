--------------------------------------------------------
--  DDL for Package PAC_CTASEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CTASEGURO" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:     PAC_CTASEGURO
      PROPÓSITO:  Funciones de cuenta seguro

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      2.0        27/04/2009   APD                2. Bug 9685 - primero se ha de buscar para la actividad en concreto
                                                    y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
      2.1        27/04/2009   APD                3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                    función pac_seguros.ff_get_actividad
      2.2        01/05/2009   JRH                7. Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      3.0        30/11/2009   NMM                8. 12101: CRE084 - Añadir rentabilidad en consulta de pólizas.
      4.0        17/12/2009   JAS                9. 0011302: CEM002 - Interface s
      5.0        21/12/2009   APD               10. Bug 12426 : se crea la funcion f_anula_linea_ctaseguro
      6.0        01/01/2009   NCC               11. Bug 12907 : Se añade el control sobre la funcion pac_seguros.f_get_sseguro si es <> retorna mensaje.
      7.0        16/02/2010   ICV               12. 0012555: CEM002 - Interficie per apertura de llibretes
      8.0        15/09/2010   JRH               16. 0012278: Proceso de PB para el producto PEA.
      9.0        22/05/2012   MDS               17. 0022339: CRE998: Moviments compte-seguro CRE054. Canvi en la fórmula càlcul de variació
     10.0        11/06/2014   JTT               18. 0029943: Añadimos un nuevo parametro a la funcion F_CIERREPB
     11.0        15/07/2014   AFM               19. 0032058: GAP. Prima de Riesgo, gastos y comisiones prepagables
     12.0        08/10/2015   JCP               12. 0033665: Validacion funcion genera recibo
   ******************************************************************************/
   FUNCTION f_numlin_next(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_numlin_next_shw(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcestado IN VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      pccapgar IN NUMBER DEFAULT NULL,
      pccapfal IN NUMBER DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL,   --JRH 01/2008 Añado psrecren el id de pagosrenta
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pcesta IN NUMBER DEFAULT NULL,
      pfecmig IN DATE DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL
)
      RETURN NUMBER;

   FUNCTION f_insctaseguro_shw(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcestado IN VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      pccapgar IN NUMBER DEFAULT NULL,
      pccapfal IN NUMBER DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pcesta IN NUMBER DEFAULT NULL,
      pfecmig IN DATE DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL
)
      RETURN NUMBER;

   FUNCTION f_aportacion_extraordinaria(
      pimporte IN NUMBER,
      pcapgarantit IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi OUT NUMBER,
      pcmotmov IN NUMBER DEFAULT 500)
      RETURN NUMBER;

   FUNCTION f_cierre_ahorro(
      pmodo IN VARCHAR2,
      pfcierre IN DATE,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      psproces OUT NUMBER,
      indice OUT NUMBER,
      indice_error OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_np_tipo_garantias(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_inscta_prov_cap_rentas(psseguro IN NUMBER)
      RETURN NUMBER;

   -- JAS 23/01/2007 - Funció que realitza el càlcul de la provisió matemàtica. Aquesta funció ja existia,
   -- però era privada de en la funció "f_reduccion_total" d'aquest mateix package.
   FUNCTION f_inscta_prov_cap(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pmodo IN VARCHAR2,
      ppsproces IN NUMBER,
      pffecmov IN DATE DEFAULT NULL)
      RETURN NUMBER;

   -- bug: 0032058
   FUNCTION f_inscta_prov_cap_shw(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pmodo IN VARCHAR2,
      ppsproces IN NUMBER,
      pffecmov IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_ins_desglose_aho(
      psseguro IN NUMBER,
      pfmovdia IN DATE,
      pcmovimi IN NUMBER,
      pseqgrupo IN NUMBER,
      pmodo IN VARCHAR2,
      pcagrpro IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_ins_desglose_aho_shw(
      psseguro IN NUMBER,
      pfmovdia IN DATE,
      pcmovimi IN NUMBER,
      pseqgrupo IN NUMBER,
      pmodo IN VARCHAR2,
      pcagrpro IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_reduccion_total(psseguro IN NUMBER, pcidioma_user IN NUMBER DEFAULT f_idiomauser)
      RETURN NUMBER;

   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   FUNCTION f_esta_reducida(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_recalcular_lineas_saldo(psseguro IN NUMBER, pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_recalcular_lineas_saldo_shw(psseguro IN NUMBER, pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_restaura_frevisio_interes(psseguro IN NUMBER, pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_garan_riesgo_suspendidas(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_garan_suspendida(psseguro IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER;

   -- RSC 04/1/2008 Función para realizar la anulación de una aportación
   -- desde el formulartio de consulta de CTASEGURO (alulk028.fmb)
   FUNCTION f_anulacion_aportacion(
      psseguro IN NUMBER,
      pctanrecibo IN NUMBER,
      paapffecmov IN DATE,
      paapfvalmov IN DATE,
      paapnnumlin IN NUMBER,
      paapimovimi IN NUMBER,
      pnrecibo IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_anulacion_aportacion_shw(
      psseguro IN NUMBER,
      pctanrecibo IN NUMBER,
      paapffecmov IN DATE,
      paapfvalmov IN DATE,
      paapnnumlin IN NUMBER,
      paapimovimi IN NUMBER,
      pnrecibo IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      f_insctasegurodetalle: Inserta un detalle de CTASEGURO
      Param IN psseguro: Seguro
      Param IN pfcontab: Fecha Contable
      Param IN pnnumlin : Línea
      Param IN pccampo : Concepto
      Param IN pvalor : Vslor del concepto
      Param IN pmodo : Modo ('P'revio o 'R'eal)
      Param IN psproces : Proceso
      retrun : 0 Si todo ha ido bien
   ****************************************************************************************/-- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION f_insctasegurodetalle(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pccampo IN VARCHAR,
      pvalor IN VARCHAR,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_suma_aportacio
      param in psseguro  : codi assegurança
      return             : suma aportació

      Bug 12101 - 30/11/2009 - NMM.
    *************************************************************************/
   FUNCTION f_suma_aportacio(p_sseguro IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      Impresió llibreta d'estalvi
      param in  pcempres:       codi d'empresa
      param in  psseguro:       sseguro de la pòlissa
      param in  pnpoliza:       npoliza de la pòlissa
      param in  pncertif:       ncertif de la pòlissa
      param in  pnpolcia:       número de pòlissa de la companyia
      param in  pvalsaldo:      flag per indicar si cal realitzar validació de saldo
      param in  pisaldo:        saldo del moviment de llibreta a partir del qual se vol imprimir (per validacions).
      param in  pcopcion:       opció d'impressió
                                    1 -> Actualització de registres pendents
                                    2 -> Reimpressió a partir de número de seqüència
      param in  pnseq:          número de seqüència a partir del qual realitzar la reimpressió (opció d'impressió 2)
      param in  pfrimpresio       Data a partir del qual realitzar la reimpressió (opció d'impressió 2)
      param in  pnmov           número de moviments a retornar (-1 vol dir tots)
      param in  porden          ordenació de la llibreta
      param in  pcidioma        idioma de les descripcions de moviments de llibreta
      param out pcur_reg_lib    cursor/llista de moviments de llibreta impressos
      return                    0/numerr -> Tot OK/error
   *************************************************************************/
   FUNCTION f_imprimir_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      pvalsaldo IN NUMBER,
      pisaldo IN NUMBER,
      pcopcion IN NUMBER,
      pnseq IN NUMBER,
      pfrimpresio IN DATE,
      pnmov IN NUMBER,
      porden IN NUMBER,
      pcidioma IN NUMBER,
      literalretorno OUT VARCHAR2,
      pcur_reg_lib OUT sys_refcursor)
      RETURN NUMBER;

    -- Bug 12426 - APD - 21/12/2009 - se crea la funcion f_anula_linea_ctaseguro
   /*************************************************************************
       Funcion que anulará una linea en ctasseguro
       param in psseguro  : póliza
       param in pfcontab  : fecha contable
       param in pnnumlin  : Número de línea de ctaseguro
       return             : 0 si todo ha ido bien o 1 si ha habido algún error
    *************************************************************************/
   FUNCTION f_anula_linea_ctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pcidioma IN NUMBER,
      pnrecibo OUT NUMBER)
      RETURN NUMBER;

   --Ini Bug.: 0012555 - ICV - 16/02/2010 - CEM002 - Interficie per apertura de llibretes
   FUNCTION f_imprimir_portada_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      pcidioma IN NUMBER,
      ptproducto OUT VARCHAR2,
      pnnumide OUT VARCHAR2,
      ptnombre OUT VARCHAR2)
      RETURN NUMBER;

--Fin Bug.: 0012555

   -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.

   /************************************************************************
      f_cierrePB
         Proceso de inserción de la PB en CTASEGURO

       Parámetros Entrada:

           psmodo : Modo ('P'revio y 'R'eal)
           pfecha : Fecha Cálculo
           pcidioma: Idioma
           pcempresa: Empresa
           pcagrpro: Agrupación
           psproduc: Producto
           psseguro: Seguro
           psprcpb: Numero de proceso anterior de calculo de la PB

       Parámetros Salida:

           psproces: Procesos
           indice : Pólizas que han ido bien
           indice_error : Pólizas que han ido mal

       retorna 0 si ha ido todo bien o código de error en caso contrario
   *************************************************************************/
   FUNCTION f_cierrepb(
      psmodo IN VARCHAR2,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      psproces OUT NUMBER,
      pindice OUT NUMBER,
      pindice_error OUT NUMBER,
      psprcpb IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-- Fi BUG 12278 -  09/2010 - JRH

   /*************************************************************************
      FUNCTION f_suma_aportacio1
      param in psseguro  : codi assegurança
      return             : suma aportació

      Bug 22339 - MDS - 22/05/2012
      -- versión de f_suma_aportacio: cmovimi = 33,34,53,47
    *************************************************************************/
   FUNCTION f_suma_aportacio1(p_sseguro IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_suma_aportacio2
      param in psseguro  : codi assegurança
      return             : suma aportació

      Bug 22339 - MDS - 22/05/2012
      -- versión de f_suma_aportacio: cmovimi = 1,2,3,4,8
    *************************************************************************/
   FUNCTION f_suma_aportacio2(p_sseguro IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_suma_aportacio3
      param in psseguro  : codi assegurança
      return             : suma aportació

      Bug 22339 - MDS - 22/05/2012
      -- versión de f_suma_aportacio: cmovimi = 10,51
    *************************************************************************/
   FUNCTION f_suma_aportacio3(p_sseguro IN VARCHAR2)
      RETURN VARCHAR2;

    /*************************************************************************
      FUNCTION f_tiene_ctashadow
      param in psseguro  : codi assegurança
      param in psproduc   : codi producte
      return             : suma aportació

   ***************************************************************************/
   FUNCTION f_tiene_ctashadow(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ctaseguro_consolidada
      param in pffecha  : data d'aplicacio
      param in pcempres   : codi empresa
      param in pccesta   : codi fondo
      param in psseguro   : codi seguro
      param in ver_shdw   : Se usa shadow
      return             : suma aportació
   ***************************************************************************/
   FUNCTION f_ctaseguro_consolidada(
      pffecha IN DATE,
      pcempres IN NUMBER,
      pccesta IN NUMBER,
      psseguro IN NUMBER,
      ver_shdw IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_genera_recibo(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfproces IN DATE,
      pfperini IN DATE,
      pfperfin IN DATE,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pimporte IN NUMBER,
      pcidioma IN NUMBER,
      pnmovimi IN NUMBER,
      pctipopago IN NUMBER,
      pnrecibo OUT NUMBER,
      psproduc NUMBER,
      pctipopu NUMBER)
      RETURN NUMBER;
END pac_ctaseguro;

/

  GRANT EXECUTE ON "AXIS"."PAC_CTASEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CTASEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CTASEGURO" TO "PROGRAMADORESCSI";
