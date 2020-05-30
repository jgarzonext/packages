--------------------------------------------------------
--  DDL for Package PAC_DOMIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DOMIS" AUTHID CURRENT_USER IS
   -- BUG 0019999 - 14/11/2011 - JMF
   k_ctipban_cobros_ach CONSTANT NUMBER := 51;

--------------------------------------------------------------
   FUNCTION f_domiciliar(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pfcobro IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      --BUG 23645 - 07/09/2012 - JTS
      pcagente IN NUMBER,
      ptagente IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pttomador IN VARCHAR2,
      pnrecibo IN NUMBER,
      --FI BUG 23645
      pcidioma IN NUMBER,
      pfitxer OUT VARCHAR2,
      pnum_ok OUT NUMBER,
      pnum_ko OUT NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------
   FUNCTION f_cobrament(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmincobdom DATE,
      pfefecto IN DATE,
      pfcobro IN DATE,
      pcidioma IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      --BUG 23645 - 07/09/2012 - JTS
      pcagente IN NUMBER,
      ptagente IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pttomador IN VARCHAR2,
      pnrecibo IN NUMBER,
      --FI BUG 23645
      pnum_ok OUT NUMBER,
      pnum_ko OUT NUMBER,
      pdomisibanxml IN NUMBER DEFAULT 1)
      RETURN NUMBER;

---------------------------------------------------------------------------------
   FUNCTION f_creafitxer(
      psproces IN NUMBER,
      ptsufpresentador IN VARCHAR2,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      ptfitxer IN VARCHAR2,
      pcidioma IN NUMBER,
      pctipemp IN NUMBER,
      ppath IN VARCHAR2)
      RETURN NUMBER;

---------------------------------------------------------------------------------
   FUNCTION f_domrecibos(
      pctipemp IN NUMBER,
      pcidioma IN NUMBER,
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      pfcobro IN DATE DEFAULT NULL   --> -- Bug.: 13498 - JGR - 04/03/2010
                                  )
      RETURN NUMBER;

---------------------------------------------------------------------------------
   FUNCTION f_fitxer_buit(psproces IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------
   -- mantis_3873
   FUNCTION f_creafitxer_iban(
      psproces IN NUMBER,
      ptsufpresentador IN VARCHAR2,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      ptfitxer IN VARCHAR2,
      pcidioma IN NUMBER,
      pctipemp IN NUMBER,
      ppath IN VARCHAR2,
      pfcobro IN DATE DEFAULT NULL   --> -- Bug.: 13498 - JGR - 04/03/2010
                                  )
      RETURN NUMBER;

-- bug 8416 - 12/12/2008 - Jorteg.a - JTS
   FUNCTION f_creafitxer_dom80(
      p_sproces IN NUMBER,
      p_tsufpresentador IN VARCHAR2,
      p_cempres IN NUMBER,
      p_cdoment IN NUMBER,
      p_cdomsuc IN NUMBER,
      p_tfitxer IN VARCHAR2,
      p_cidioma IN NUMBER,
      p_ctipemp IN NUMBER,
      p_path IN VARCHAR2)
      RETURN NUMBER;

-- bug 11339 - 08/10/2009 - JGM -
   /*************************************************************************
       FUNCTION f_retorna_select
       Función que retornará la select de PREVIO_DOMICILIACIONES
       Ejemplo: 01/01/2009, null,null,null,2

       param in fefecto: VARCHAR2 - Obligatoria - Fecha Efecto (formato DD/MM/YYYY)
       param in cramo:   NUMBER - Opcional - Codigo Ramo
       param in sproduc: NUMBER - Opcional - Codigo Producto
       param in cempres: NUMBER - Opcional - Codigo Empresa
       param in FiltradoMaximo: BOOLEAN (defecto FALSE)- Será TRUE si se llama por pantalla para filtrar el numero de resultados.
       param in pccobban  : Código de cobrador bancario
       param in pcbanco   : Código de banco
       param in pctipcta  : Tipo de cuenta
       param in pfvtotar  : Fecha de vencimiento tarjeta
       param in pcreferen : Código de referencia
       return             : Devolverá un VARCHAR2 con la SELECT usada en Map, pantalla y proceso.
   *************************************************************************/
   FUNCTION f_retorna_query(
      fefecto IN VARCHAR2,
      cramo IN NUMBER,
      psproduc IN NUMBER,
      cempres IN NUMBER,
      psprodom IN NUMBER DEFAULT NULL,
      filtradomaximo IN BOOLEAN DEFAULT FALSE,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN VARCHAR2 DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      -- Código Mediador -- 8. 0021718 / 0111176 - Inicio
      ptagente IN VARCHAR2 DEFAULT NULL,   -- Nombre Mediador
      pnnumide IN VARCHAR2 DEFAULT NULL,   -- Nif Tomador
      pttomador IN VARCHAR2 DEFAULT NULL,   -- Nombre Tomador
      pnrecibo IN NUMBER DEFAULT NULL   -- Recibo          -- 8. 0021718 / 0111176 - Fin
                                     )
      -- FIN BUG 18825 - 19/07/2011 - JMP
   RETURN VARCHAR2;

   -- Bug 15750 - FAL - 20/08/2010 - Permitir seleccionar productos en el proceso domiciliación
   /*******************************************************************************
   FUNCION F_INSERT_TMP_DOMISAUX
   Función que insertará en la tabla temporal los productos seleccionados para el
   proceso de domiciliación de recibos.
   Parámetros:
    Entrada :
       Pcempres  NUMBER
       Psproces  NUMBER
       Psproduc  NUMBER
       Pseleccio NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_insert_tmp_domisaux(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER)
      RETURN NUMBER;

-- FI Bug 15750 - FAL - 20/08/2010 - Permitir seleccionar productos en el proceso domiciliación

   -- Bug 19986 - APD - 04/11/2011 - se crea la funcion
   /*******************************************************************************
   FUNCION f_agrupa_recibos_domiciliados
   Función que agrupa recibos domiciliados.
   Se agrupan los recibos con la misma cuenta bancaria
   Parámetros:
    Entrada :
       Psproces  NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_agrupa_recibos_domiciliados(psproces IN NUMBER)
      RETURN NUMBER;

-- FI Bug 19986 - APD - 04/11/2011

   -- Bug 19986 - APD - 07/11/2011 - se crea la funcion
   /*******************************************************************************
   FUNCION f_desagrupa_recibos_domici
   Función que desagrupa recibos domiciliados.
   Parámetros:
    Entrada :
       Psproces  NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_desagrupa_recibos_domici(pnrecibo IN NUMBER)
      RETURN NUMBER;

   -- Bug 19999 - APD - 07/11/2011 - se crea la funcion
   /*******************************************************************************
   FUNCION f_estado_domiciliacion
   Función que modifica el estado de los recibos domiciliados.
   Parámetros:
    Entrada :
       Psproces  NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_estado_domiciliacion(
      pcempres IN NUMBER DEFAULT pac_md_common.f_get_cxtempresa,
      psproces IN NUMBER,
      pnrecibo IN NUMBER,
      pcestrec IN NUMBER,
      pnum_ok OUT NUMBER,
      pnum_ko OUT NUMBER,
      pfdebito IN DATE DEFAULT NULL   -- 9. 0021663 / 0109768
                                   )
      RETURN NUMBER;

   -- Bug 21116 - APD - 27/01/2012 - se crea la funcion
   /*******************************************************************************
   FUNCION f_valida_domi_cobban
   Función que valida que si existe una domiciliación en curso para un cobrador bancario,
   no permita realizar una nueva domiciliación de este cobrador bancario
   Parámetros:
    Entrada :
       pcempres NUMBER
       pccobban  NUMBER
       psseguro IN NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_valida_domi_cobban(
      pcempres IN NUMBER,
      pccobban IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL,
      psproces IN NUMBER DEFAULT NULL)   -- 8.JGR 21120: LCOL897-LCOL_A001- Nota: 0109527
      RETURN NUMBER;

   -- ini BUG 21318 : MDS : 13/02/2012
   /*************************************************************************
       FUNCTION f_retorna_query2 (evolución de la f_retorna_query)
       Función que retornará la select de PREVIO_DOMICILIACIONES

       param in fefecto: VARCHAR2 - Obligatoria - Fecha Efecto (formato DD/MM/YYYY)
       param in cramo:   NUMBER - Opcional - Codigo Ramo
       param in sproduc: NUMBER - Opcional - Codigo Producto
       param in cempres: NUMBER - Opcional - Codigo Empresa
       param in FiltradoMaximo: BOOLEAN (defecto FALSE)- Será TRUE si se llama por pantalla para filtrar el numero de resultados.
       param in pccobban  : Código de cobrador bancario
       param in pcbanco   : Código de banco
       param in pctipcta  : Tipo de cuenta
       param in pfvtotar  : Fecha de vencimiento tarjeta
       param in pcreferen : Código de referencia
       return             : Devolverá un VARCHAR2 con la SELECT usada en Map, pantalla y proceso.
   *************************************************************************/
   FUNCTION f_retorna_query2(
      fefecto IN VARCHAR2,
      cramo IN NUMBER,
      psproduc IN NUMBER,
      cempres IN NUMBER,
      psprodom IN NUMBER DEFAULT NULL,
      filtradomaximo IN BOOLEAN DEFAULT FALSE,
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

-- fin BUG 21318 : MDS : 13/02/2012

   -- 11. 0023645: MDP_A001-Correcciones en Domiciliaciones - 0131871 - Inicio
   FUNCTION f_age_ctipmed05(pnrecibo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_creafitxer_acuerdo(
      psproces IN NUMBER,
      ptsufpresentador IN VARCHAR2,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      ptfitxer IN VARCHAR2,
      pcidioma IN NUMBER,
      pctipemp IN NUMBER,
      ppath IN VARCHAR2)
      RETURN NUMBER;

-- 11. 0023645: MDP_A001-Correcciones en Domiciliaciones - 0131871 - Fin
   -- 13. 0025032: LCOL_T001-QT 5464: ERROR CAMBIO DE TOMADOR IAXIS POLIZA 666
/*******************************************************************************
   FUNCION f_valida_domi_poliza
   Función que valida que si existe una domiciliación en curso para una póliza
   Parámetros:
    Entrada :
      psseguro IN NUMBER
   Retorna: un NUMBER con el id del error.
********************************************************************************/
   FUNCTION f_valida_domi_poliza(psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

--13. 0025032: LCOL_T001-QT 5464: ERROR CAMBIO DE TOMADOR IAXIS POLIZA 666  Fin

   --14. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
/*******************************************************************************
   FUNCION f_agrupa_rec_domis
   Devuelve COBBANCARIO.CAGRUPREC que determina si corresponde agrupar los recibos
   en los procesos de domiciliaciones
   Ya NO se hará por parametro de productos 'RECUNIF' (como anteriormente)
   Parámetros:
    Entrada :
      psseguro IN NUMBER
   Retorna: un NUMBER con el id del error.
********************************************************************************/
   FUNCTION f_agrupa_rec_domis(pccobban IN NUMBER, pcempres IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/*******************************************************************************
   FUNCION f_agrupa_rec_tipo
   Nos informa del tipo de agrupación que deberemos aplicar a los recibos
   Tiene prioridad el de domiciliaciones, después el de producción

   Devuelve
      4 - Agrpación de domiciliaciones
      1,2 o 3 - Tipos agrupación de Prod ('RECUNIF')

   Parámetros:
    Entrada :
      pccobban IN NUMBER
      pcempres IN NUMBER
   Retorna: un NUMBER con el id del error.
********************************************************************************/
   FUNCTION f_agrupa_rec_tipo(
      pccobban IN NUMBER,
      pcempres IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/*******************************************************************************
   FUNCION f_desagrupa_rec
         -- Desunificar recibos (solo si es de domiciliaciones [sdomunif is not null]):
         -- 1. Guardamos al agrupación de recibos en el histórico
         -- 2. La eliminamos

   Parámetros:
    Entrada :
      pnrecibo IN NUMBER

   Retorna: un NUMBER con el id del error.
********************************************************************************/
   FUNCTION f_desagrupa_rec(pnrecibo IN NUMBER)
      RETURN NUMBER;

--41. MMM - 0027598 LCOL_A003-Error en la informacion del campo de matricula generado en el archivo previo de domiciliacion - QT-8390 - Inicio
/*******************************************************************************
   FUNCION f_get_notificaciones_idnotif2
         -- Descripcion
         -- Devuelve la matricula a partir de un sseguro y ctipban
   Parámetros:
    Entrada :
      pnrecibo psseguro IN seguros.sseguro%TYPE
      pcbancar IN recibos.cbancar%TYPE
      pctipban recibos.ctipban%TYPE

   Retorna: un VARCHAR2 con la matrícula
********************************************************************************/
   FUNCTION f_get_notificaciones_idnotif2(
      psseguro IN seguros.sseguro%TYPE,
      pcbancar IN recibos.cbancar%TYPE,
      pctipban IN recibos.ctipban%TYPE)
      RETURN VARCHAR2;

--41. MMM - 0027598 LCOL_A003-Error en la informacion del campo de matricula generado en el archivo previo de domiciliacion - Fin
   PROCEDURE p_recibo_nombre(
      p_proceso IN NUMBER,
      p_seguro IN NUMBER,
      p_idioma IN OUT NUMBER,
      p_nombre IN OUT VARCHAR2,
      p_sperson IN OUT NUMBER,
      p_domici IN OUT VARCHAR2);

   /*******************************************************************************
   FUNCION f_convertir_ccc_ibaN
         -- Descripcion
   Parámetros:
    Entrada :
      pccc: Cuenta Bancaria de la que queremos obtener el IBAN
      pPais: País al que pertenece la cuenta bancaria

     Retorna el IBAN correspondiente a la cuenta bancaria
   ********************************************************************************/
   FUNCTION f_convertir_ccc_iban(pccc IN VARCHAR2, ppais IN VARCHAR2)
      RETURN VARCHAR2;

   /*******************************************************************************
   FUNCION f_set_domiciliaciones_sepa
         Proceso que guarda los datos en la tablas de domiliaciones_sepa**
   ********************************************************************************/
   FUNCTION f_set_domiciliaciones_sepa(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      pfcobro IN DATE)
      RETURN NUMBER;

   FUNCTION f_get_ident_interv(
      pnif IN VARCHAR2,
      psufix IN VARCHAR2,
      pidpais IN VARCHAR2,
      pidinterv OUT VARCHAR2)
      RETURN NUMBER;
END pac_domis;

/

  GRANT EXECUTE ON "AXIS"."PAC_DOMIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DOMIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DOMIS" TO "PROGRAMADORESCSI";
