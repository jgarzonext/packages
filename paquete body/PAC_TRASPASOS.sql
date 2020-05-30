--------------------------------------------------------
--  DDL for Package Body PAC_TRASPASOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_TRASPASOS" AS
   /******************************************************************************
     NOMBRE:       PAC_traspasos
     PROPÓSITO:  Package para gestionar los traspasos

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        06/11/2009   ICV                1. Creación del package. (bug 10124)
     2.0        11/02/2009   DRA                2. 0013030: CEM - Grabar traspasos migrados
     3.0        29/06/2010   PFA                3. 15197: CEM210 - La data 'Fecha antigüedad' no es recupera correctament de la taula
     4.0        14/07/2010   SRA                2. 0015372: CEM210 - Errores en grabación y gestión de traspasos de salida
     5.0        22/07/2010   SRA                5. 0015489: CEM - LListat de traspassos
     6.0        03/08/2010   RSC                6. CEM - Q234 TRANSFERENCIA SALIDA DE PPA A PPI
     7.0        04/08/2010   RSC                7. CEM - traspassos de salida ppa
     8.0        14/09/2010 - RSC                8. 0015618: Q234 TRANSFERENCIA SALIDA DE PPA A PPI
     9.0        06/10/2010   FAL                9. 0016219: GRC - Pagos de siniestros de dos garantías
     9.0        18/10/2010   SRA                9. 0016259: HABILITAR CAMPOS DE TEXTO ESPECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
     10.0       18/11/2010   RSC                10.0016747: GENERACIÓN 234 SALIDAS NO LO HACE BIEN
     11.0       14/03/2011   APD                11.0015707: ENSA102 - Valors liquidatius - Estat actual
     12.0       11/04/2011   APD                12. 0018225: AGM704 - Realizar la modificación de precisión el cagente
     13.0       13/05/2011   JMF                13. 0018536 CX - Modificar dades fiscals del traspàs de sortida - Cálculo de primas_consumidas en Traspasos
     14.0       20/06/2011   DRA                14. 0018821: ERROR EN TRASPASOS ENTRADA
     15.0       22/06/2011   RSC                15. 0018851: ENSA102 - Parametrización básica de traspasos de Contribución definida
     16.0       29/10/2011   JMC                15. 0019601: LCOL_S001-SIN - Subestado del pago
     17.0       20/10/2011   RSC                17. 0019425/94998: CIV998-Activar la nova gestio de traspassos
     18.0       08/11/2011   JMP                18. 0018423: LCOL000 - Multimoneda
     18.0       27/12/2011   JMP                19. 0018423: LCOL705 - Multimoneda
     19.0       10/01/2012   JMF                20. 0020856: ENSA800 - Controlar importe traspaso de SALIDA parcial
     20.0       03/04/2012   MDS                21. 0021883: CIV998-DWH_Traspasos

   ******************************************************************************/

   /*************************************************************************
      FUNCTION F_GET_TRASPASOS
      Función que sirve para recuperar una colección de traspasos.
        1.  PSPRODUC: Tipo numérico. Parámetro de entrada. Código de producto.
        2.  PFILTROPROD: Tipo carácter. Parámetro de entrada. Valor 'TRASPASO'.
        3.  NPOLIZA: Tipo numérico. Parámetro de entrada. Id. de póliza.
        4.  NCERTIF: Tipo numérico. Parámetro de entrada. Id. de certificado
        5.  PNNUMNIDE: Tipo carácter. Parámetro de entrada. Documento.
        6.  PBUSCAR: Tipo carácter. Parámetro de entrada. Nombre de la persona.
        7.  PTIPOPERSONA: Tipo numérico. Parámetro de entrada. Indica si buscamos por Tomador o Asegurado
        8.  PSNIP: Tipo carácter. Parámetro de entrada. Número d'identificador.
        9.  PCINOUT: Tipo numérico. Parámetro de entrada. Traspasos de entrada o salida
        10. PCESTADO: Tipo numérico. Parámetro de entrada. Indica el estado.
        11. PFSOLICI: Tipo fecha. Parámetro de entrada. Fecha solicitud.
        12. PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total o Parcial
        13. PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo importe Potser sobra o millor algun altre paràmetre com PCTIPDER.
        14. PCERROR: Tipo numérico. Parámetro de Salida. 0 si todo ha ido correctamente o un código identificativo si ha habido algún error.
   Retorna una colección SYS_REF_CURSOR
       *************************************************************************/
   FUNCTION f_get_traspasos(
      psproduc IN NUMBER,   -- Código de producto
      cramo IN NUMBER,   -- Código de ramo
      pfiltroprod IN VARCHAR2,   -- Valor ‘TRASPASO’
      npoliza IN NUMBER,   -- Id  de póliza
      ncertif IN NUMBER,   -- Id  de certificado
      pnnumnide IN VARCHAR2,   -- Documento
      pbuscar IN VARCHAR2,   -- Nombre de la persona
      ptipopersona IN NUMBER,   -- Indica si buscamos por Tomador o Asegurado
      psnip IN VARCHAR2,   -- Número d’identificador
      pcinout IN NUMBER,   -- Traspasos de entrada o salida
      pcestado IN NUMBER,   -- Indica el estado
      pfsolici IN DATE,   -- Fecha solicitud
      pctiptras IN NUMBER,   -- Total o Parcial
      pctiptrassol IN NUMBER,   -- Tipo importe
      pmodo IN VARCHAR2,   -- Mode amb que es entra a fer traspasos (Anulacio, revocació, solicitud...)
      pcerror OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(4000);
      buscar         VARCHAR2(4000) := '';   --' and(s.cagente,s.cempres) in (select cagente,cempres from agentes_agente) ';
      /* BUG 15372 - 13/07/2010 - SRA - condiciones de filtrado que se aplican a traspasos sin seguro informado */
      buscar2        VARCHAR2(4000);
      v_tfsolici     VARCHAR2(10);
      subus          VARCHAR2(500);
      tabtp          VARCHAR2(10);
      auxnom         VARCHAR2(200);
      nerr           NUMBER;
      v_sentence     VARCHAR2(500);
      v_max_reg      NUMBER;   -- número màxim de registres mostrats
      -- Bug 15618 - RSC - 14/09/2010 - Q234 TRANSFERENCIA SALIDA DE PPA A PPI
      v_noenlaza     VARCHAR2(4000) := '';
   -- Fin Bug 15618
   BEGIN
      IF NVL(psproduc, 0) <> 0 THEN
         buscar := buscar || '';   --' and s.sproduc =' || psproduc;
      ELSE
         nerr := pac_productos.f_get_filtroprod(pfiltroprod, v_sentence);

         IF nerr <> 0 THEN
            pcerror := nerr;
            RAISE e_object_error;
         END IF;

         IF v_sentence IS NOT NULL THEN
            buscar := buscar || ' and s.sproduc in (select p.sproduc from productos p where'
                      || v_sentence || ' 1=1)';
         END IF;

         IF cramo IS NOT NULL THEN
            buscar := buscar || ' and s.sproduc in (select p.sproduc from productos p where'
                      || ' p.cramo = ' || cramo || ' )';
         END IF;
      END IF;

      IF npoliza IS NOT NULL
         AND NVL(pmodo, '') NOT LIKE 'TR%' THEN
         buscar := buscar || ' and s.npoliza = ' || CHR(39) || npoliza || CHR(39);
      END IF;

      IF NVL(ncertif, -1) <> -1 THEN
         buscar := buscar || '  and s.ncertif =' || ncertif;
      END IF;

      -- buscar per personas
      IF (pnnumnide IS NOT NULL
          OR NVL(psnip, ' ') <> ' '
          OR pbuscar IS NOT NULL)
         AND NVL(ptipopersona, 0) > 0 THEN
         IF ptipopersona = 1 THEN   -- Prenador
            tabtp := 'TOMADORES';
         ELSIF ptipopersona = 2 THEN   -- Asegurat
            tabtp := 'ASEGURADOS';
         END IF;

         IF tabtp IS NOT NULL THEN
            subus :=
               ' and s.sseguro IN
                           (SELECT a.sseguro
                              FROM '
               || tabtp
               || ' a, personas p
                                WHERE a.sperson = p.sperson';

            IF pnnumnide IS NOT NULL THEN
               subus := subus || ' AND p.nnumnif  = ''' || pnnumnide || '''';
            END IF;

            IF NVL(psnip, ' ') <> ' ' THEN
               subus := subus || ' AND upper(p.snip)=upper(''' || psnip || ''')';
            END IF;

            IF pbuscar IS NOT NULL THEN
               nerr := f_strstd(pbuscar, auxnom);
               subus := subus || ' AND upper(p.tbuscar) like upper(''%' || auxnom || '%'')';
            END IF;

            subus := subus || ')';
         END IF;
      END IF;

      IF pcinout IS NOT NULL THEN
         buscar := buscar || ' and traspaso.cinout = ' || CHR(39) || pcinout || CHR(39);
         buscar2 := buscar2 || ' and traspaso.cinout = ' || CHR(39) || pcinout || CHR(39);
      END IF;

      IF pcestado IS NOT NULL THEN
         buscar := buscar || ' and traspaso.cestado = ' || CHR(39) || pcestado || CHR(39);
         buscar2 := buscar2 || ' and traspaso.cestado = ' || CHR(39) || pcestado || CHR(39);
      END IF;

      IF pmodo IS NOT NULL THEN
         IF pmodo = 'ANUL_SOL_TRASPAS' THEN
            buscar := buscar || ' and traspaso.cestado IN (1,2,8)';   --JGM: bug 15895 - 09/09/2010 - ponia IN (3)
         ELSIF pmodo = 'REVOCACIO_TRAS_EXT' THEN
            buscar := buscar || ' and traspaso.cestado IN (2, 3, 8)';
         ELSIF pmodo LIKE 'TR%' THEN
            buscar := buscar || ' and traspaso.cestado IN (1, 2, 6) and s.sseguro = '
                      || npoliza || ' and traspaso.stras <> ' || SUBSTR(pmodo, 3);
         END IF;
      END IF;

      /* BUG 15372 - 06/07/2010 - SRA - truncamos la fecha fsolici */
      IF pfsolici IS NOT NULL THEN
         --       buscar := buscar || ' and to_date(traspaso.fsolici,''dd/mm/yyyy'') = to_date('
         --                 || CHR(39) || pfsolici || CHR(39) || ',''dd/mm/yyyy'') ';
         v_tfsolici := TO_CHAR(pfsolici, 'dd/mm/yyyy');
         buscar := buscar || ' and trunc(traspaso.fsolici) = to_date(''' || v_tfsolici
                   || ''', ''dd/mm/yyyy'') ';
         buscar2 := buscar2 || ' and trunc(traspaso.fsolici) = to_date(''' || v_tfsolici
                    || ''', ''dd/mm/yyyy'') ';
      END IF;

      IF pctiptras IS NOT NULL THEN
         buscar := buscar || ' and traspaso.ctiptras = ' || CHR(39) || pctiptras || CHR(39);
         buscar2 := buscar2 || ' and traspaso.ctiptras = ' || CHR(39) || pctiptras || CHR(39);
      END IF;

      IF pctiptrassol IS NOT NULL THEN
         buscar := buscar || ' and traspaso.ctiptrassol = ' || CHR(39) || pctiptrassol
                   || CHR(39);
         buscar2 := buscar2 || ' and traspaso.ctiptrassol = ' || CHR(39) || pctiptrassol
                    || CHR(39);
      END IF;

      -- Bug 15618 - RSC - 14/09/2010 - Q234 TRANSFERENCIA SALIDA DE PPA A PPI
      IF NOT(npoliza IS NOT NULL
             AND NVL(pmodo, '') NOT LIKE 'TR%') THEN
         v_noenlaza :=
            ' UNION ALL '
            || 'select
                   traspaso.stras,
                   null,
                   null npoliza,'
            || 'null, NULL ncertif,
                   null sproduc,
                   null,' || 'null,' || 'null,' || 'NULL,' || 'null,' || 'null,'
            || 'null,
                   traspaso.fsolici, traspaso.cinout,'
            || 'FF_DESVALORFIJO(679,f_usu_idioma,traspaso.cinout) ,' || 'traspaso.ctiptras, '
            || 'FF_DESVALORFIJO(676,f_usu_idioma,traspaso.ctiptras) ,'
            || 'traspaso.cexterno,
                   null,' ||   --traspaso.textern,
                            'traspaso.ctipder,
                   null,' ||   --traspaso.tctipder,
                            'traspaso.cestado, '
            || 'FF_DESVALORFIJO(675,f_usu_idioma,traspaso.cestado) ,'
            || 'traspaso.ctiptrassol,
                   FF_DESVALORFIJO(330,f_usu_idioma,traspaso.ctiptrassol),'
            || 'traspaso.iimptemp,
                   traspaso.nporcen, traspaso.nparpla, traspaso.iimporte, traspaso.fvalor,
                   null,'
            || 'traspaso.nnumlin,
                   null,'
            || 'traspaso.ccodpla,
                   traspaso.tcodpla, traspaso.ccompani, traspaso.tcompani, traspaso.ctipban,
                   traspaso.cbancar, traspaso.tpolext, traspaso.ncertext,
                   null,'
            || 'traspaso.fantigi, traspaso.iimpanu, traspaso.nparret,
                   traspaso.iimpret, traspaso.nsinies, traspaso.nparpos2006, traspaso.porcpos2006,
                   traspaso.nparant2007 , traspaso.porcant2007, traspaso.tmemo,traspaso.srefc234, traspaso.cenvio, '
            || 'FF_DESVALORFIJO(331,f_usu_idioma,traspaso.cenvio) '
            || 'FROM trasplainout traspaso where sseguro is null '
                                                                  /* BUG 15372 - 13/07/2010 - SRA - condiciones de filtrado que se aplican a traspasos sin seguro informado */
            || buscar2;
      END IF;

      -- Fin Bug 15618
      squery :=
         'select
               traspaso.stras,
               s.sseguro,
               null,'
         ||   --s.nriesgo,
           's.npoliza, s.ncertif,
               s.sproduc,
               null,' ||   --traspaso.cagrpro,
                        'null,' ||   --traspaso.sperstom,
                                  'null,'
         ||   --traspaso.nniftom,
           'PAC_IAX_LISTVALORES.F_Get_NameTomador(s.sseguro,1),' ||   --traspaso.tnomtom,
                                                                   'null,' ||   --traspaso.spersase,
                                                                             'null,'
         ||   --traspaso.nnifase,
           'null,
               traspaso.fsolici, traspaso.cinout,'
         || 'FF_DESVALORFIJO(679,f_usu_idioma,traspaso.cinout) ,' || 'traspaso.ctiptras, '
         || 'FF_DESVALORFIJO(676,f_usu_idioma,traspaso.ctiptras) ,'
         || 'traspaso.cexterno,
               null,' ||   --traspaso.textern,
                        'traspaso.ctipder,
               null,' ||   --traspaso.tctipder,
                        'traspaso.cestado, '
         || 'FF_DESVALORFIJO(675,f_usu_idioma,traspaso.cestado) ,'
         || 'traspaso.ctiptrassol,
               FF_DESVALORFIJO(330,f_usu_idioma,traspaso.ctiptrassol),'
         ||   --traspaso.tctiptrassol,
           'traspaso.iimptemp,
               traspaso.nporcen, traspaso.nparpla, traspaso.iimporte, traspaso.fvalor,
               null,'
         ||   --traspaso.fefecto,
           'traspaso.nnumlin,
               null,'
         ||   --traspaso.fcontab,
           'traspaso.ccodpla,
               traspaso.tcodpla, traspaso.ccompani, traspaso.tcompani, traspaso.ctipban,
               traspaso.cbancar, traspaso.tpolext, traspaso.ncertext,
               null,'
         ||   --traspaso.ssegext,

           --traspaso.planp,
         'traspaso.fantigi, traspaso.iimpanu, traspaso.nparret,
               traspaso.iimpret, traspaso.nsinies, traspaso.nparpos2006, traspaso.porcpos2006,
               traspaso.nparant2007 , traspaso.porcant2007, traspaso.tmemo,traspaso.srefc234, traspaso.cenvio, '
         || 'FF_DESVALORFIJO(331,f_usu_idioma,traspaso.cenvio)'
         || ' from seguros s, trasplainout traspaso where s.sseguro = traspaso.sseguro '
         || buscar || subus
                           ---------------- part sseguro null
                           -- Bug 15618 - RSC - 14/09/2010 - Q234 TRANSFERENCIA SALIDA DE PPA A PPI
         || v_noenlaza
-- Fin Bug 15618
----------------------------------
         || ' order by npoliza desc, ncertif desc';

      IF cur%ISOPEN THEN
         CLOSE cur;
      END IF;

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN e_object_error THEN
         pcerror := 1;
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_get_traspasos', 99, nerr, SQLERRM);
         RETURN NULL;
      -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona WHEN OTHERS
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
   END f_get_traspasos;

   /*************************************************************************
   FUNCTION F_GET_TRASPASO
   Función que sirve para recuperar los datos de un traspaso.
        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  NUM_ERR: Tipo numérico. Parámetro de Salida. 0 si todo ha ido correcto y sino código identificativo de error.

   Retorna una colección T_IAX_TRASPASOS con UN SOLO TRAPASO
    *************************************************************************/
   FUNCTION f_get_traspaso(pstras IN NUMBER, num_err OUT NUMBER)
      RETURN sys_refcursor IS
      vcur           sys_refcursor;
      vquery         VARCHAR2(5000);
   BEGIN
      IF pstras IS NULL THEN
         num_err := -1;
         RETURN NULL;
      ELSE
         vquery :=

            --JGM: Los campos que faltan los podemos sacar de donde salen en GET_TRASPASOS...
            'SELECT decode(traspaso.ctipban,1,substr(traspaso.cbancar,1,4)||''-''|| substr(traspaso.cbancar,5,4)||''-''||substr(traspaso.cbancar,9,2)||''-''||substr(traspaso.cbancar,11,10),traspaso.cbancar) CBANCAR,'
            || ' planpensiones.coddgs ccodpla, traspaso.tcodpla, traspaso.ccompani, traspaso.tcompani, traspaso.cestado,'
            || ' traspaso.cexterno, traspaso.cinout, traspaso.ctipban, traspaso.ctipder,'
            || ' traspaso.ctiptras, traspaso.ctiptrassol, traspaso.fantigi, traspaso.fsolici,'
            || ' traspaso.fvalor, traspaso.iimpanu, traspaso.iimporte, traspaso.iimpret,'
            || ' traspaso.iimptemp, traspaso.ncertext, traspaso.nnumlin, traspaso.nparant2007,'
            || ' traspaso.nparpla, traspaso.nparpos2006, traspaso.nparret, traspaso.nporcen,'
            || ' traspaso.porcant2007, traspaso.porcpos2006, traspaso.nsinies, '
            || ' traspaso.sseguro, traspaso.stras, traspaso.tcodpla, traspaso.tmemo, traspaso.tpolext,'
            || ' s.cagrpro,s.sproduc,traspaso.srefc234,traspaso.cenvio,traspaso.ccodpla, traspaso.cmotrod, traspaso.fefecto '
            -- Bug 16259 - SRA - 18/10/2010: recuperamos en la consulta los campos de "contingencia acaecida" y "fecha de contingencia"
            || ',traspaso.ctipcont, traspaso.fconting '
            || ' from seguros s, trasplainout traspaso, planpensiones'
            || ' where planpensiones.ccodpla(+)=traspaso.ccodpla'
            || ' and s.sseguro = traspaso.sseguro and stras = ' || pstras;

         OPEN vcur FOR vquery;

         num_err := 0;
         RETURN vcur;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF vcur%ISOPEN THEN
            CLOSE vcur;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_TRASPASOS.f_get_traspaso', 1,
                     'pstras: ' || pstras, SQLCODE || ' - ' || SQLERRM);
         num_err := SQLCODE;
         RETURN NULL;
   END;

    /*************************************************************************
       FUNCTION 4.3.1.6.1.3   F_SET_TRASPASO
        Función que sirve para insertar o actualizar datos del traspaso. Sólo se puede utilizar
        si el traspaso esta en estado Sin confirmar o Confirmado.
        Parámetros

        1. PSSEGURO:Tipo numérico. Parámetro de entrada. Identificador de póliza.
        2. PSPRODUC: Tipo numérico. Parámetro de entrada. Identificador de producto.
        3. PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        4. PFSOLICI:Tipo fecha. Parámetro de entrada. Fecha de solicitud.
        5. PCINOUT: Tipo numérico. Parámetro de entrada. Entrada / Salida
        6. PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total / Parcial
        7. PCEXTERN: Tipo numérico. Parámetro de entrada. Interno / Externo
        8. PCTIPDER: Tipo numérico. Parámetro de entrada. Traspasa derechos económicos o consolidados.
        9. PCESTADO: Tipo numérico. Parámetro de entrada. Sin Confirmar / Confirmado / …..
        10.   PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo de traspaso solictado.
        11.   PIIMPTEMP: Tipo numérico. Parámetro de entrada. Importe Solicitado
        12.   NPORCEN: Tipo numérico. Parámetro de entrada. Porcentaje solicitado.
        13.   NPARPLA: Tipo numérico. Parámetro de entrada. Participaciones solicitadas.
        14.   CCOPLA: Tipo numérico. Parámetro de entrada. Código de Plan del o al que se traspasa.
        15.   TCCODPLA:Tipo Carácter. Parámetro de entrada. Nombre del plan del o al que se traspasa.
        16.   CCOMPANI: Tipo Numérico. Parámetro de entrada. Código de compañía del o al que se traspasa
        17.   TCOMPANI: Tipo Carácter. Parámetro de entrada. Nombre de compañía del o al que se traspasa
        18.   CTIPBAN:Tipo de cuenta. Parámetro de entrada. Tipo de cuenta del plan al que se traspasa
        19.   CBANCAR: Tipo Carácter. Parámetro de entrada. Cuenta del plan al que se traspasa
        20.   TPOLEXT: Tipo Carácter. Parámetro de entrada. Código identificativo de la póliza (o plan) del o al que se traspasa,
        21.   NCERTEXT: Tipo numérico. Parámetro de entrada. Núm. de certificado cuando el traspaso es interno, entre planes o pólizas de planes de pensiones.
        22.   CCODPLA: Tipo numérico. Parámetro de entrada. Código del plan.
        23.   TCODPLA: Tipo carácter. Parámetro de entrada. Nombre del plan.
        24.   FANTIGI:Tipo fecha. Parámetro de entrada. Fecha de antigüedad de las aportaciones del plan origen.
        25.   IIMPANU: Tipo numérico. Parámetro de entrada. Aportaciones del año de traspaso en el plan origen.
        26.   NPARRET: Tipo numérico. Parámetro de entrada. Participaciones retenidas para contingencias posteriores.
        27.   IIMPRET: Tipo numérico. Parámetro de entrada. Importe retenido para contingencias posteriores a la primera contingencia.
        28.   NPARPOS2006: Tipo numérico. Parámetro de entrada. Participaciones posteriores al año 2006.
        29.   PORCPOS2006: Tipo numérico. Parámetro de entrada. Porcentaje de las participaciones posteriroes al año 2006.
        30.   NPARANT2007: Tipo numérico. Parámetro de entrada. Participaciones anteriores al año 2007.
        31.   PORCANT2007: Tipo numérico. Parámetro de entrada. Porcentaje de participaciones anteriores al año 2007.
        32.   TMEMO:Tipo Carácter. Parámetro de entrada. Comentarios / observaciones relacionadas con el traspaso.
        33.   NREF:Tipo Carácter. Parámetro de entrada. Referencia del traspaso enviado o que se envía en la Norma234
        34.   PSTRAS: Tipo numérico. Parámetro de entrada/salida. Código de traspaso.
        Retorna un valor numérico: 0 si ha grabado el traspaso y 1 si se ha producido algún error.
   *************************************************************************/
   FUNCTION f_set_traspaso(
      ppsseguro IN NUMBER,
      ppfsolici IN DATE,
      ppcinout IN NUMBER,
      ppctiptras IN NUMBER,
      ppcextern IN NUMBER,
      ppctipder IN NUMBER,
      ppcestado IN NUMBER,
      ppctiptrassol IN NUMBER,
      ppiimptemp IN NUMBER,
      nnporcen IN NUMBER,
      nnparpla IN NUMBER,
      cccodpla IN NUMBER,
      ttccodpla IN VARCHAR2,
      cccompani IN NUMBER,
      ttcompani IN VARCHAR2,
      cctipban IN NUMBER,
      ccbancar IN VARCHAR2,
      ttpolext IN VARCHAR2,
      nncertext IN NUMBER,
      ffantigi IN DATE,
      iiimpanu IN NUMBER,
      nnparret IN NUMBER,
      iiimpret IN NUMBER,   --es en realidad iimporte.
      nnparpos2006 IN NUMBER,
      pporcpos2006 IN NUMBER,
      nnparant2007 IN NUMBER,
      pporcant2007 IN NUMBER,
      ttmemo IN VARCHAR2,
      nnref IN VARCHAR2,
      ccmotivo IN NUMBER,
      ffefecto IN DATE,
      ffvalor IN DATE,
-- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
      pctipcont IN NUMBER,
      pfcontig IN DATE,
      pctipcap IN NUMBER,
      pimporte IN NUMBER,
      pfpropag IN DATE,
-- Fin Bug 16259 - SRA - 20/10/2010
      ppstras IN OUT NUMBER)
      RETURN NUMBER IS
      vcodi_pla      trasplainout.tcodpla%TYPE;   --       vcodi_pla      NUMBER(10); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xiiimpret      trasplainout.ncertext%TYPE;   --       xiiimpret      NUMBER(15, 4); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      IF ppcestado IN(1, 2, 4) THEN   -- BUG13030:DRA:11/02/2010
         IF ppstras IS NULL THEN   --insert
            SELECT stras.NEXTVAL
              INTO ppstras
              FROM DUAL;

            /*IF cccodpla IS NOT NULL THEN   --esto en realidad es un CODDGS busco el CODPLA DE VERDAD
               BEGIN
                  SELECT ccodpla
                    INTO vcodi_pla
                    FROM planpensiones
                   WHERE coddgs = cccodpla;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN -2;   -- no existeix el codi de pla
               END;
            ELSE
               vcodi_pla := NULL;
            END IF;*/
            vcodi_pla := cccodpla;

            IF ppcinout = 1
               AND iiimpret IS NULL
               AND ppiimptemp IS NOT NULL THEN
               xiiimpret := ppiimptemp;
            ELSE
               xiiimpret := iiimpret;
            END IF;

            INSERT INTO trasplainout
                        (stras, sseguro, fsolici, cinout, ctiptras,
                         cexterno, ctipder, cestado, ctiptrassol, iimptemp,
                         nporcen, nparpla, ccodpla, tcodpla, ccompani,
                         tcompani, ctipban, cbancar, tpolext, ncertext,
                         fantigi, iimpanu, nparret, iimporte, nparpos2006, porcpos2006,
                         nparant2007, porcant2007, tmemo, srefc234, cmotrod,
                         -- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
                         ctipcont, fconting,
                                            -- Fin Bug 16259 - SRA - 20/10/2010
                                            fefecto, fvalor, festado)
                 VALUES (ppstras, ppsseguro, ppfsolici, ppcinout, ppctiptras,
                         NVL(ppcextern, 0), ppctipder, ppcestado, ppctiptrassol, ppiimptemp,
                         nnporcen, nnparpla, vcodi_pla, SUBSTR(ttccodpla, 1, 60), cccompani,
                         SUBSTR(ttcompani, 1, 40), cctipban, ccbancar, ttpolext, nncertext,
                         ffantigi, iiimpanu, nnparret, xiiimpret, nnparpos2006, pporcpos2006,
                         nnparant2007, pporcant2007, SUBSTR(ttmemo, 1, 500), nnref, ccmotivo,
                         -- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
                         pctipcont, pfcontig,
                                             -- Fin Bug 16259 - SRA - 20/10/2010
                                             ffefecto, ffvalor, f_sysdate);

            COMMIT;
            RETURN 0;
         ELSE   --update
            /*IF cccodpla IS NOT NULL THEN   --esto en realidad es un CODDGS busco el CODPLA DE VERDAD
               BEGIN
                  SELECT ccodpla
                    INTO vcodi_pla
                    FROM planpensiones
                   WHERE coddgs = cccodpla;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN -2;   -- no existeix el codi de pla
               END;
            ELSE
               vcodi_pla := NULL;
            END IF;*/
            vcodi_pla := cccodpla;

            IF ppcinout = 1
               AND iiimpret IS NULL
               AND ppiimptemp IS NOT NULL THEN
               xiiimpret := ppiimptemp;
            ELSE
               xiiimpret := iiimpret;
            END IF;

            UPDATE trasplainout
               SET sseguro = ppsseguro,
                   fsolici = ppfsolici,
                   cinout = ppcinout,
                   ctiptras = ppctiptras,
                   cexterno = NVL(ppcextern, 0),
                   ctipder = ppctipder,
                   cestado = ppcestado,
                   ctiptrassol = ppctiptrassol,
                   iimptemp = ppiimptemp,
                   nporcen = nnporcen,
                   nparpla = nnparpla,
                   ccodpla = vcodi_pla,
                   tcodpla = SUBSTR(ttccodpla, 1, 60),
                   ccompani = cccompani,
                   tcompani = SUBSTR(ttcompani, 1, 40),
                   ctipban = cctipban,
                   cbancar = ccbancar,
                   tpolext = ttpolext,
                   ncertext = nncertext,
                   fantigi = ffantigi,
                   iimpanu = iiimpanu,
                   nparret = nnparret,
                   iimporte = xiiimpret,
                   nparpos2006 = nnparpos2006,
                   porcpos2006 = pporcpos2006,
                   nparant2007 = nnparant2007,
                   porcant2007 = pporcant2007,
                   tmemo = SUBSTR(ttmemo, 1, 500),
                   srefc234 = NVL(nnref, srefc234),   -- Bug 15627 - RSC - 03/08/2010 - CEM - Q234 TRANSFERENCIA SALIDA DE PPA A PPI
                   fefecto = ffefecto,
                   fvalor = ffvalor,
                   festado = NVL(festado, f_sysdate),
                   -- Ini Bug 16259 - SRA - 20/10/2010
                   ctipcont = pctipcont,
                   fconting = pfcontig,
                   -- Fin Bug 16259 - SRA - 20/10/2010
                   cmotrod = ccmotivo
             WHERE stras = ppstras;

            -- Ini Bug 16259 - SRA - 20/10/2010: si el traspaso tiene derechos económicos, entonces podemos actualizarlos
            IF pctipcont IS NOT NULL THEN
               UPDATE trasplapresta
                  SET ctipcap = pctipcap,
                      importe = pimporte,
                      fpropag = pfpropag
                WHERE stras = ppstras;
            END IF;

            -- Fin Bug 16259 - SRA - 20/10/2010
            COMMIT;
            RETURN 0;
         END IF;
      ELSE
         RETURN -1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_set_traspaso', 99, SQLCODE, SQLERRM);
         RETURN SQLCODE;
   END f_set_traspaso;

      /*************************************************************************
      FUNCTION F_DEL_TRASPASO
       Función que sirve para borrar los datos del traspaso. Sólo se puede utilizar
       si el traspaso esta en estado Sin confirmar. Y sólo se permite a un perfil de seguridad

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.

   Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_del_traspaso(pstras IN NUMBER)
      RETURN NUMBER IS
      v_estado       trasplainout.cestado%TYPE;   --       v_estado       NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      IF pstras IS NULL THEN
         RETURN -1;
      ELSE
         SELECT cestado
           INTO v_estado
           FROM trasplainout
          WHERE stras = pstras;

         IF v_estado = 1 THEN
            RETURN -1;
         ELSE
            DELETE      trasplainout
                  WHERE stras = pstras;

            RETURN 0;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_del_traspaso', 99, SQLCODE, SQLERRM);
         RETURN -1;
   END;

   /*************************************************************************
   FUNCTION F_ACTEST_TRASPASO
       Función que sirve para actualizar el estado de un traspaso.

         1. PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
         2. PCESTADO: Tipo numérico. Parámetro de entrada. Código de estado.

    Retorna un valor numérico: 0 si ha grabado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_actest_traspaso(
      pstras IN NUMBER,
      pcestado IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      cmotivo IN NUMBER)
      RETURN NUMBER IS
      v_return       NUMBER := 0;
      v_motivo       trasplainout.cmotrod%TYPE := cmotivo;   --       v_motivo       NUMBER(3) := cmotivo; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      IF pstras IS NULL
         OR pcestado IS NULL THEN
         RETURN -1;
      ELSE
         UPDATE trasplainout
            SET cestado = pcestado,
                cmotrod = v_motivo,
                festado = f_sysdate
          WHERE stras = pstras;

         IF pcestado = 2
            AND pinout = 1
            AND pextern = 1 THEN
            v_return := f_enviar_traspaso(pstras);
         END IF;

         IF pcestado = 8
            AND pinout = 2
            AND pextern = 1 THEN
            v_return := f_enviar_traspaso(pstras);
         END IF;

         IF pcestado = 6
            AND pinout = 2
            AND pextern = 1 THEN
            v_return := f_enviar_traspaso(pstras);
         END IF;

         COMMIT;
         RETURN v_return;
      END IF;
   END;

   /*************************************************************************
   FUNCTION F_ENVIAR_TRASPASO
       Función que sirve para actualizar el estado de un traspaso.

         1. PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.

    Retorna un valor numérico: 0 si ha grabado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_enviar_traspaso(pstras IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pstras IS NULL THEN
         RETURN -1;
      ELSE
         UPDATE trasplainout
            SET cenvio = 0
          WHERE stras = pstras;

         COMMIT;
         RETURN 0;
      END IF;
   END;

      /*************************************************************************
      FUNCTION F_OUT_PARTIC
       Función que realiza un traspaso de salida.
       Esta función adapta y actualiza la función PK_TRASPASOS.F_OUT_PARTIC.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total / Parcial
        3.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        4.  PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        5.  PFVALMOV: Tipo fecha. Parámetro de entrada. Fecha de valor del traspaso.
        6.  PFEFECTO: Tipo fecha. Parámetro de entrada. Fecha de efecto del traspaso.
        7.  PIMOVIMI: Tipo numérico. Parámetro de entrada. Importe del traspaso en dinero
        8.  PPARTRAS: Tipo numérico. Parámetro de entrada. Importe del traspaso en participaciones.
        9.  PNPORCEN: Tipo numérico. Parámetro de entrada. Porcentaje a traspasar.
        10. PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Indicador del tipo de importe a traspasar (importe, porcentaje...)
        11. PCEXTERN: Tipo numérico. Parámetro de entrada. Interno / Externo
        12. PSSEGURO_OR: Tipo numérico. Parámetro de entrada. Póliza destino si es traspaso interno.
        13. PAUTOMATIC: Tipo numérico. Parámetro de entrada. Indica si el traspaso inverso se ejecuta o no (evitar bucles infinitos en traspasos internos).
        14. PPORDCONS: Tipo numérico. Parámetro de entrada. Porcentaje.
        15. PPORDECON: Tipo numérico. Parámetro de entrada. Porcentaje.
        16. PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.

   Retorna un valor numérico: 0 si ha ejecutado el traspaso y un código identificativo de error si se ha producido algún problema.
       *************************************************************************/
   FUNCTION f_out_partic(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pcagrpro IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pnporcen IN OUT NUMBER,
      pctiptrassol IN NUMBER,
      pcextern IN NUMBER,
      psseguro_ds IN NUMBER,
      pautomatic IN NUMBER,
      ppordcons IN NUMBER,
      ppordecon IN NUMBER,
      psproces IN NUMBER,
      ptipder IN NUMBER)
      RETURN NUMBER IS
      ---
      --
      -- Bug 0020856 - JMF - 10/01/2012
      vobj           VARCHAR2(100) := 'pac_traspasos.f_out_partic';
      vpas           NUMBER := 1;
      vpar           VARCHAR2(500)
         := '' || ' s=' || pstras || ' t=' || pctiptras || ' s=' || psseguro || ' a='
            || pcagrpro || ' v=' || pfvalmov || ' e=' || pfefecto || ' i=' || pimovimi
            || ' p=' || ppartras || ' n=' || pnporcen || ' t=' || pctiptrassol || ' e='
            || pcextern || ' d=' || psseguro_ds || ' a=' || pautomatic || ' o=' || ppordcons
            || ' d=' || ppordecon || ' s=' || psproces || ' t=' || ptipder;
      --
      --
      num_err        NUMBER;
      xnsinies       NUMBER;
      xsidepag       pagosini.sidepag%TYPE;   --       xsidepag       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnnumlin       trasplainout.nnumlin%TYPE;   --       xnnumlin       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfcontab       trasplainout.fcontab%TYPE;   --       xfcontab       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ximovimi       trasplainout.iimptemp%TYPE;                                                    /* NUMBER(15, 2);    */
                                                   /*      xsaldo         NUMBER(15, 2);      */
      xpartras       NUMBER;   /*NUMBER(25, 6);*/
      pspersdest     per_personas.sperson%TYPE;   --       pspersdest     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pspertipdestinat NUMBER(2);
      pstrasin       NUMBER(8);
      xepagsin       NUMBER(1);
      xfantigi       trasplainout.fantigi%TYPE := NULL;   --       xfantigi       DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--      ximpanu        NUMBER(25, 10) := 0;
      xaportacions   ctaseguro.imovimi%TYPE;   --trasplainout.ipritar%TYPE := 0;   --       xaportacions   NUMBER(25, 10) := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xmesaporta     NUMBER;   /*NUMBER(25, 10) := 0;       */
      ---
      xctipban       trasplainout.ctipban%TYPE;
      xcbancar       trasplainout.cbancar%TYPE;
      ---
      errorts        EXCEPTION;
      errorte        EXCEPTION;
      errorprimas    EXCEPTION;
      error228       EXCEPTION;
      vcagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
      vfvalmov       DATE;
      vfefecto       trasplainout.fefecto%TYPE;   --       vfefecto       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pccodpla       trasplainout.ccodpla%TYPE;
      pccompani      trasplainout.ccompani%TYPE;
      xcporcant2007  trasplainout.porcant2007%TYPE;
      -- Bug 15658 - 04/08/2010 - RSC - CEM - traspassos de salida ppa
      xcporcpos2006  trasplainout.porcpos2006%TYPE;
      -- Fin Bug 15658

      -- Bug 16747 - RSC - 18/11/2010 - GENERACIÓN 234 SALIDAS NO LO HACE BIEN (añadimos MIN(fantigi)
      xfantigi_r     trasplainout.fantigi%TYPE;
      -- Fin Bug 16747

      -- ini Bug 0020856 - JMF - 10/01/2012
      v_cinout       trasplainout.cinout%TYPE;
      v_iprovmat     NUMBER;
      v_porc_max_traspsal NUMBER;
      -- fin Bug 0020856 - JMF - 10/01/2012
      vtraza         NUMBER := 0;
      tdiv           NUMBER;
      valortrasp     NUMBER;
      vsseguro       NUMBER;
      vpro           NUMBER;
      xivalora       NUMBER;
      partis_incorporadas NUMBER;
   BEGIN
      ---Comprovació paràmetres
      IF pfvalmov IS NULL THEN
         vfvalmov := TRUNC(f_sysdate);
      ELSE
         vfvalmov := pfvalmov;
      END IF;

      IF pfefecto IS NULL THEN
         vfefecto := TRUNC(f_sysdate);
      ELSE
         vfefecto := pfefecto;
      END IF;

      vtraza := 1;

      --DBMS_OUTPUT.put_line(vpar);

      --p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_out_partic', 97,
      --               'vpar=' || vpar, num_err);
      IF pctiptras = 2
         AND(pimovimi = 0
             OR pimovimi IS NULL)
         AND(ppartras = 0
             OR ppartras IS NULL)
         AND(pnporcen = 0
             OR pnporcen IS NULL) THEN
         num_err := 107839;
         RAISE errorts;
      END IF;

      vtraza := 2;

      --Bug10612 - 03/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      -- Bug 0016747 - RSC - 18/11/2010 - GENERACIÓN 234 SALIDAS NO LO HACE BIEN (añadimos MIN(fantigi)
      -- Bug 0020856 - JMF - 10/01/2012: CINOUT
      SELECT MAX(ccodpla), MAX(ccompani), MAX(ctipban), MAX(cbancar), MAX(porcant2007),
             MAX(porcpos2006), MIN(fantigi), MAX(cinout)
        INTO pccodpla, pccompani, xctipban, xcbancar, xcporcant2007,
             xcporcpos2006, xfantigi_r, v_cinout
        FROM trasplainout
       WHERE stras = pstras;

      vtraza := 3;

      -- ini Bug 0020856 - JMF - 10/01/2012
      IF v_cinout = 2
         AND pctiptras = 2 THEN   -- Salida Parcial
         v_iprovmat := pac_isqlfor.f_provisio_actual(psseguro, 'IPROVAC', vfefecto);

         IF v_iprovmat IS NULL THEN
            -- Provisión insuficiente para realizar el traspaso
            RETURN 9903169;
         END IF;

         vtraza := 4;

         SELECT NVL(pac_parametros.f_parempresa_n(cempres, 'PORC_MAX_TRASPSAL'), 100)
           INTO v_porc_max_traspsal
           FROM seguros
          WHERE sseguro = psseguro;

         IF pimovimi >(v_iprovmat *(v_porc_max_traspsal / 100)) THEN
            -- El importe del traspaso, supera el porcentaje máximo permitido de la provisión de la póliza
            RETURN 9903109;
         END IF;
      END IF;

      vtraza := 5;

      -- fin Bug 0020856 - JMF - 10/01/2012

      -- Fin bug 0016747
      IF pccodpla IS NOT NULL THEN
         BEGIN
            SELECT p.sperson
              INTO pspersdest
              FROM per_personas p, planpensiones, fonpensiones
             WHERE fonpensiones.ccodfon = planpensiones.ccodfon
               AND p.sperson = fonpensiones.sperson
               AND planpensiones.ccodfon = fonpensiones.ccodfon
               AND planpensiones.ccodpla = pccodpla;
         EXCEPTION
            WHEN OTHERS THEN
               pspersdest := NULL;
         END;
      ELSIF pccompani IS NOT NULL THEN
         BEGIN
            SELECT p.sperson
              INTO pspersdest
              FROM per_personas p, aseguradoras a
             WHERE a.ccodaseg = pccompani
               AND p.sperson = a.sperson;
         EXCEPTION
            WHEN OTHERS THEN
               pspersdest := NULL;
         END;
      ELSE
         ----ERROR
         NULL;
      END IF;

      vtraza := 6;
      --FI Bug10612 - 03/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      pspertipdestinat := 5;

      IF pcextern = 1 THEN
         xepagsin := 2;
      ELSIF pcextern <> 1 THEN
         xepagsin := 1;
      END IF;

      num_err := f_out(pstras, pctiptras, psseguro, 1,   --JGM:Risc a pelo 1
                       pcagrpro, vfvalmov, vfefecto, pimovimi, ppartras, pspersdest, xepagsin,
                       xcbancar, xctipban, NULL,   -- JGM: psproces
                       xnnumlin, xfcontab);

      IF num_err <> 0 THEN
         RAISE errorts;
      END IF;

      vtraza := 7;
      -- alberto TODO HA IDO BIEN
      num_err := f_llenar_primas(pstras, pstras);   --JRH IMP

      IF num_err <> 0 THEN
         RAISE errorprimas;
      END IF;

      num_err := f_llenar_datos_228(pstras, pstras);   --JRH IMP

      IF num_err <> 0 THEN
         RAISE error228;
      END IF;

      vtraza := 8;

      -- Bug 18851 - RSC - 22/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      SELECT cempres
        INTO vcempres
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) <> 1 THEN
         -- Fin bug 18851

         -- Bug 0016747 - RSC - 18/11/2010 - GENERACIÓN 234 SALIDAS NO LO HACE BIEN (xfantigi_r)
         SELECT LEAST(NVL(MIN(fantigi), TO_DATE('31/12/2999', 'DD/MM/YYYY')),
                      LEAST(MIN(s.fefecto), xfantigi_r))
           INTO xfantigi
           FROM seguros s, trasplainout t
          WHERE s.sseguro = t.sseguro(+)
            AND s.sseguro = psseguro
            AND t.cinout(+) = 1;

         vtraza := 9;

         -- FInb ug 16747
         BEGIN
            SELECT SUM(NVL(imovimi, 0))
              INTO xaportacions
              FROM ctaseguro
             WHERE ctaseguro.sseguro = psseguro
               AND ctaseguro.cmovimi IN(1, 2)
               AND ctaseguro.cmovanu NOT IN(1)
               AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(pfvalmov, 'YYYY');

            SELECT SUM(NVL(iimpanu, 0))
              INTO xmesaporta
              FROM trasplainout
             WHERE trasplainout.sseguro = psseguro
               AND trasplainout.cinout = 1
               AND cestado IN(3, 4);

            xaportacions := NVL(xaportacions, 0) + NVL(xmesaporta, 0);
         END;
      -- Bug 18851 - RSC - 22/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      END IF;

      vtraza := 10;

      -- Fin bug 18851
      IF pcextern <> 1
         AND psseguro_ds IS NOT NULL THEN
         IF pautomatic = 1 THEN
            ---*** Si el traspàs es de sortida cap a un altre pla de l'empresa
            ---*** hem de crear un traspàs d'entrada
            xpartras := 0;
            num_err :=
               f_traspaso_inverso(   --JGM: 1,
                                  pstras, psseguro_ds, NULL, psseguro,   --JGM: No va al reves respecte l'altre?
                                  NULL, ptipder,   --JGM: Quin valor de risc, el busco per sseguro?
                                  pimovimi, pnporcen, xpartras, pctiptras, pctiptrassol, 1,
                                  pstrasin, NULL   --JGM: Quin valor de procés
                                                );
            vtraza := 11;

            IF num_err <> 0 THEN
               RAISE errorte;
            END IF;

            num_err := f_in_partic(pstrasin, pctiptras, psseguro_ds, pcagrpro, vfvalmov,
                                   vfefecto, pimovimi, xpartras, pnporcen, pctiptrassol,
                                   pcextern, psseguro, 0, ppordcons, ppordecon, NULL, ptipder);   --JGM: Proces);
            vtraza := 12;

            IF num_err <> 0 THEN
               RAISE errorte;
            END IF;
         END IF;
      END IF;

      ---*** Actualizamos el traspaso
      -- Bug 18851 - RSC - 22/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) <> 1 THEN
         -- Fin Bug 18851
         BEGIN
            UPDATE trasplainout
               SET fantigi = xfantigi,
                   iimpanu = NVL(iimpanu, xaportacions),   -- Bug 15658 - 04/08/2010 - RSC - CEM - traspassos de salida ppa
                   cestado = 4,
                   festado = f_sysdate,
                   iimporte = pimovimi,
                   nnumlin = xnnumlin,
                   fcontab = xfcontab,
                   fefecto = vfefecto   -- Bug 13979 - RSC - 15/09/2010 - 00: Llistat traspassos
             WHERE stras = pstras;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 151254;
         END;

         vtraza := 13;
      -- Bug 18851 - RSC - 22/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      ELSE
         BEGIN
            UPDATE trasplainout
               SET cestado = 9,
                   festado = f_sysdate,
                   iimporte = pimovimi,
                   fefecto = vfefecto
             WHERE stras = pstras;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 151254;
         END;

         vtraza := 14;
      END IF;

      -- Fin bug 18851

      ---*** Actualizamos también si salida,i porcentajes 2006 y 2007 nulos

      -- Bug 18851 - RSC - 22/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) <> 1 THEN
         -- Fin Bug 18851
         vtraza := 15;

         -- Bug 15658 - 04/08/2010 - RSC - CEM - traspassos de salida ppa
         IF xcporcpos2006 IS NOT NULL THEN
            UPDATE trasplainout
               SET porcant2007 = 100 - xcporcpos2006
             WHERE stras = pstras;

            vtraza := 16;
         ELSE
            -- Fin Bug 15658
            IF NVL(xcporcant2007, 0) = 0 THEN
               DECLARE
                  suma_ant       NUMBER;   /* NUMBER(15, 3);     */
                  suma_pos       NUMBER;   /* NUMBER(15, 3);        */
                  porcen         trasplainout.porcant2007%TYPE;   --                   porcen         NUMBER(6, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
               BEGIN
                  SELECT NVL(SUM(ircm + ipricons), 0)
                    INTO suma_ant
                    FROM primas_consumidas p, ctaseguro c
                   WHERE NVL(c.fectrasp, p.fecha) <= TO_DATE('31/12/2006', 'DD/MM/YYYY')
                     AND c.sseguro = p.sseguro
                     AND c.nnumlin = p.nnumlin
                     -- AND frescat = f_sysdate;
                     AND p.nsinies = (SELECT nsinies
                                        FROM trasplainout
                                       WHERE stras = pstras);   --JRH IMP

                  vtraza := 17;

                  SELECT NVL(SUM(ircm + ipricons), 0)
                    INTO suma_pos
                    FROM primas_consumidas p, ctaseguro c
                   WHERE NVL(c.fectrasp, p.fecha) > TO_DATE('31/12/2006', 'DD/MM/YYYY')
                     -- AND frescat = f_sysdate;
                     AND c.sseguro = p.sseguro
                     AND c.nnumlin = p.nnumlin
                     AND p.nsinies = (SELECT nsinies
                                        FROM trasplainout
                                       WHERE stras = pstras);   --JRH IMP

                  vtraza := 18;

                  IF pctiptras = 1
                     OR(suma_ant + suma_pos <= pimovimi) THEN   -- TOTAL o [PARCIAL pero no tinc prou diners]
                     IF (suma_ant + suma_pos) <= 0 THEN
                        porcen := 0;
                     ELSE
                        porcen := (suma_ant * 100) /(suma_ant + suma_pos);   --distribueixo en % sobre el total del que tinc
                     END IF;
                  ELSE   --Parcial i tinc prou diners
                     IF suma_ant <= pimovimi THEN
                        porcen := 100;   -- tot surt dels ANTERIORS A 2007
                     ELSE
                        porcen := (suma_ant * 100) / pimovimi;   -- Miro quin % del demanat correspon el total dels ANT2007 (la resta sera POST)
                     END IF;
                  END IF;

                  vtraza := 20;

                  UPDATE trasplainout
                     SET porcant2007 = porcen,
                         porcpos2006 = 100 - porcen
                   WHERE stras = pstras;

                  IF pstrasin IS NOT NULL THEN   --Actualizamos traspaso de salida interno --JRH
                     SELECT iimptemp, sseguro
                       INTO valortrasp, vsseguro
                       FROM trasplainout
                      WHERE stras = pstrasin;

                     SELECT sproduc
                       INTO vpro
                       FROM seguros
                      WHERE sseguro = vsseguro;

                     -- calcular las participaciones
                     IF NVL(f_parproductos_v(vpro, 'ES_PRODUCTO_INDEXADO'), 0) = 0 THEN
                        -- = 0 no es de inversiones
                        xivalora := 1;
                     ELSE
                        xivalora := f_valor_participlan(vfvalmov, vsseguro, tdiv);
                     END IF;

                     partis_incorporadas := ROUND(valortrasp / xivalora, 6);

                     UPDATE trasplainout
                        SET porcant2007 = porcen,
                            porcpos2006 = 100 - porcen,
                            nparant2007 = ROUND(partis_incorporadas * porcen / 100, 6),
                            nparpos2006 = partis_incorporadas
                                          - ROUND(partis_incorporadas * porcen / 100, 6)
                      WHERE stras = pstrasin;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 151254;
               END;
            END IF;
         END IF;
      -- Bug 18851
      END IF;

      vtraza := 20;

      -- Fin bug 18851
      IF num_err = 0 THEN
         COMMIT;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN errorts THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_out_partic', vtraza,
                     'psseguro=' || psseguro, num_err);

         IF num_err = 1 THEN
            RETURN 140977;
         ELSE
            RETURN num_err;
         END IF;
      WHEN errorte THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_out_partic', vtraza,
                     'psseguro=' || psseguro, 151255);
         RETURN 151255;
      WHEN errorprimas THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'f_llenar_primas', vtraza, 'psseguro=' || psseguro,
                     151255);
         RETURN 151255;
      WHEN error228 THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'f_llenar_datos', vtraza, 'psseguro=' || psseguro,
                     151255);
         RETURN 151255;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_out_partic', vtraza, SQLCODE,
                     SQLERRM);
         RETURN 140977;
   END f_out_partic;

   /*************************************************************************
   FUNCTION F_IN_PARTIC
    Función que realiza un traspaso de salida.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total / Parcial
        3.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        4.  PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        5.  PFVALMOV: Tipo fecha. Parámetro de entrada. Fecha de valor del traspaso.
        6.  PFEFECTO: Tipo fecha. Parámetro de entrada. Fecha de efecto del traspaso.
        7.  PIMOVIMI: Tipo numérico. Parámetro de entrada. Importe del traspaso en dinero
        8.  PPARTRAS: Tipo numérico. Parámetro de entrada. Importe del traspaso en partici2paciones.
        9.  PNPORCEN: Tipo numérico. Parámetro de entrada. Porcentaje a traspasar.
        10. PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Indicador del tipo de importe a traspasar (importe, porcentaje...)
        11. PCEXTERN: Tipo numérico. Parámetro de entrada. Interno / Externo
        12. PSSEGURO_OR: Tipo numérico. Parámetro de entrada. Póliza destino si es traspaso interno.
        13. PAUTOMATIC: Tipo numérico. Parámetro de entrada. Indica si el traspaso inverso se ejecuta o no (evitar bucles infinitos en traspasos internos).
        14. PPORDCONS: Tipo numérico. Parámetro de entrada. Porcentaje.
        15. PPORDECON: Tipo numérico. Parámetro de entrada. Porcentaje.
        16. PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.


    Retorna un valor numérico: 0 si ha ejecutado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_in_partic(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pcagrpro IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pnporcen IN OUT NUMBER,
      pctiptrassol IN NUMBER,
      pcextern IN NUMBER,
      psseguro_or IN NUMBER,
      pautomatic IN NUMBER,
      ppordcons IN NUMBER,
      ppordecon IN NUMBER,
      psproces IN NUMBER,
      ptipder IN NUMBER)
      RETURN NUMBER IS
      ---
      num_err        NUMBER(8);
      xfantigi       trasplainout.fantigi%TYPE;   --       xfantigi       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfefecte       seguros.fefecto%TYPE;   --       xfefecte       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
--      ximpanu        NUMBER(25, 10);
      xaportacions   trasplainout.iimpanu%TYPE;   --       xaportacions   NUMBER(25, 10); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xmesaporta     NUMBER;   /*NUMBER(25, 10);   */
      xestado        trasplainout.cestado%TYPE;   --       xestado        NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnnumlin       trasplainout.nnumlin%TYPE;   --       xnnumlin       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfcontab       trasplainout.fcontab%TYPE;   --       xfcontab       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnrecibo       NUMBER;
      pstrasin       NUMBER(8);
      ximovimi       trasplainout.iimptemp%TYPE;   /* NUMBER(15, 2);         */
      xparpla        NUMBER;   /*NUMBER(25, 10);  */
      xivalora       NUMBER;   /*NUMBER(25, 10);     */
      tdiv           NUMBER(3);
      partis_incorporadas trasplainout.nparpla%TYPE;   --       partis_incorporadas NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_porcant2007  trasplainout.porcant2007%TYPE;   --       v_porcant2007  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_porcpos2006  trasplainout.porcpos2006%TYPE;   --       v_porcpos2006  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nparant2007  trasplainout.nparant2007%TYPE;   --       v_nparant2007  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nparpos2006  trasplainout.nparpos2006%TYPE;   --       v_nparpos2006  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vfvalmov       DATE;
      vfefecto       DATE;   --trasplainout.icapital%TYPE;   --       vfefecto       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ---
      errorte        EXCEPTION;
      errorts        EXCEPTION;
      errorprimas    EXCEPTION;
      error228       EXCEPTION;
      -- Bug 18851 - RSC - 27/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      vcempres       seguros.cempres%TYPE;
      -- Fin Bug 18851
      v_sproduc      seguros.sproduc%TYPE;   -- Bug 21883 - MDS - 03/04/2012
      vtraza         NUMBER := 0;
   BEGIN
      ximovimi := pimovimi;

      IF pfvalmov IS NULL THEN
         vfvalmov := TRUNC(f_sysdate);
      ELSE
         vfvalmov := pfvalmov;
      END IF;

      IF pfefecto IS NULL THEN
         vfefecto := TRUNC(f_sysdate);
      ELSE
         vfefecto := pfefecto;
      END IF;

      IF pcextern <> 1
         AND psseguro_or IS NULL THEN
         num_err := 107839;
         RAISE errorte;
      END IF;

      IF pcextern = 1
         AND(pimovimi = 0
             OR pimovimi IS NULL) THEN
         num_err := 107839;
         RAISE errorte;
      END IF;

      vtraza := 1;

      IF pcextern <> 1
         AND(NVL(pimovimi, 0) = 0
             AND pctiptras = 2)
         AND(ppartras = 0
             OR ppartras IS NULL)
         AND(pnporcen = 0
             OR pnporcen IS NULL) THEN
         num_err := 107839;
         RAISE errorte;
      END IF;

      vtraza := 2;

      -- Bug 18851 - RSC - 27/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      SELECT cempres
        INTO vcempres
        FROM seguros
       WHERE sseguro = psseguro;

      -- Fin Bug 18851
      IF pcextern <> 1
         AND pautomatic = 1 THEN
         ---*** Si el traspàs es d'entrada cap a un altre pla de l'empresa
         ---*** hem de fer primer un traspàs de sortida
         ---Calculem l'import del traspàs de sortida que sera
         -- El introduit si ES IMPORT
         -- Calculat si es PARTICIPACIÓ
         -- No fem res si es PERCENT.
         IF pimovimi IS NOT NULL
            AND pimovimi <> 0 THEN
            ximovimi := pimovimi;
            xparpla := NULL;
         ELSIF ppartras IS NOT NULL
               AND ppartras <> 0 THEN
            ximovimi := NULL;
            xivalora := f_valor_participlan(vfvalmov, psseguro, tdiv);
            ximovimi := f_round(xivalora * ppartras, tdiv);
            xparpla := NULL;
         ELSIF pctiptrassol IN(2, 3) THEN
            --JGM: Paso del que em diu l'usuari al camp IMPORT
            -- i ho calculo per formules
            ximovimi := NULL;
         END IF;

         vtraza := 3;
         -- Bug 18851 - RSC - 27/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
         --IF NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) <> 1 THEN
         -- Fin Bug 18851
         num_err :=
            f_traspaso_inverso(   --JGM: 1,
                               pstras, psseguro,   --JGM: No va al reves respecte l'altre?
                               NULL,   --JGM: Quin valor de risc, el busco per sseguro?
                               psseguro_or,   --JGM: No va al reves respecte l'altre?
                               NULL, ptipder,   --JGM: Quin valor de risc, el busco per sseguro?
                               ximovimi, pnporcen, xparpla, pctiptras, pctiptrassol, 2,
                               pstrasin, NULL   --JGM: Quin valor de procés
                                             );

         IF num_err <> 0 THEN
            RAISE errorts;
         END IF;

         vtraza := 4;
         num_err := f_out_partic(pstrasin, pctiptras, psseguro_or, pcagrpro,   -- JGM: quin valor de pcagrpro
                                 vfvalmov, vfefecto, ximovimi, xparpla, pnporcen, pctiptrassol,
                                 pcextern, psseguro, 0, ppordcons, ppordecon, NULL,
                                 ptipder   -- JGM: quin valor de proces
                                        );

         IF num_err <> 0 THEN
            RAISE errorts;
         END IF;

         vtraza := 5;
         -- alberto TODO HA IDO BIEN
         --DBMS_OUTPUT.put_line('llamamos a llenar_primas');
         num_err := f_llenar_primas(pstrasin, pstras);   --JRH IMP

         IF num_err <> 0 THEN
            RAISE errorprimas;
         END IF;

         num_err := f_llenar_datos_228(pstrasin, pstras);   --JRH IMP

         IF num_err <> 0 THEN
            RAISE error228;
         END IF;

         IF num_err <> 0 THEN
            RAISE errorts;
         END IF;

         -- Bug 18851 - RSC - 27/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
         --END IF;
         -- Fin Bug 18851
         pimovimi := ximovimi;
      END IF;

      vtraza := 6;
      num_err := f_in(pstras, psseguro, NULL,   -- JGM: quin valor de pcagrpro
                      NULL,   -- JGM: busquem el risc per sseguro
                      vfvalmov, vfefecto, ximovimi, NULL,   --JGM: Quin valor de proces
                      xnnumlin, xfcontab, xnrecibo);

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      -- Bug 18851 - RSC - 27/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) <> 1 THEN
         -- Fin Bug 18851

         -- Ini Bug 21883 - MDS - 03/04/2012
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         -- calcular las participaciones
         IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 0 THEN
            -- = 0 no es de inversiones
            xivalora := 1;
         ELSE
            xivalora := f_valor_participlan(vfvalmov, psseguro, tdiv);
         END IF;

         vtraza := 7;

         -- Fin Bug 21883 - MDS - 03/04/2012
         SELECT NVL(porcant2007, 0), NVL(porcpos2006, 0)
           INTO v_porcant2007, v_porcpos2006
           FROM trasplainout
          WHERE stras = pstras;

         IF pstrasin IS NOT NULL THEN   --JRH El de salida que se ha hecho es el que nos da estos %
            SELECT NVL(porcant2007, 0), NVL(porcpos2006, 0)
              INTO v_porcant2007, v_porcpos2006
              FROM trasplainout
             WHERE stras = pstrasin;
         END IF;

         IF NVL(v_porcant2007, 0) <> 0
            AND NVL(v_porcpos2006, 0) <> 0 THEN   --jrh entendemos que no viene directamente de la pantalla;
            IF (v_porcant2007 + v_porcpos2006) <> 100 THEN   --JRH
               RAISE errorte;
            END IF;
         END IF;

         vtraza := 8;

         IF NVL(xivalora, 0) > 0 THEN
            partis_incorporadas := ROUND(pimovimi / xivalora, 6);

            IF v_porcant2007 > 0 THEN
               v_nparant2007 := ROUND(partis_incorporadas * v_porcant2007 / 100, 6);
            ELSE
               v_nparant2007 := 0;
            END IF;

            IF v_porcpos2006 > 0 THEN
               v_nparpos2006 := partis_incorporadas - v_nparant2007;   -- JRH ROUND(partis_incorporadas * v_porcpos2006 / 100, 6);
            ELSE
               v_nparpos2006 := 0;
            END IF;
         END IF;

         vtraza := 9;

         -- *** Actualitzem traspàs d'entrada (només per traspassos totals)
         IF pcextern = 0
            AND pctiptras = 1 THEN
            SELECT SUM(NVL(imovimi, 0))
              INTO xaportacions
              FROM ctaseguro
             WHERE ctaseguro.sseguro = psseguro_or
               AND ctaseguro.cmovimi IN(1, 2)
               AND ctaseguro.cmovanu NOT IN(1)
               AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(vfvalmov, 'YYYY');

            SELECT SUM(NVL(iimpanu, 0))
              INTO xmesaporta
              FROM trasplainout
             WHERE trasplainout.sseguro = psseguro_or
               AND trasplainout.cinout = 1
               AND cestado IN(3, 4);

            xaportacions := NVL(xaportacions, 0) + NVL(xmesaporta, 0);

            /***********
            IF pctiptras = 0 THEN
               xaportacions := 0;
            END IF;
            ***************/
            SELECT fefecto
              INTO xfefecte
              FROM seguros
             WHERE sseguro = psseguro_or;

            vtraza := 10;

            DECLARE
               xmintras       DATE;
            BEGIN
               SELECT MIN(fantigi)
                 INTO xmintras
                 FROM trasplainout
                WHERE sseguro = psseguro_or
                  AND cinout = 1
                  AND fantigi IS NOT NULL
                  AND cestado = 4;

               IF xmintras IS NULL
                  OR NVL(TO_CHAR(xfantigi, 'YYYYMMDD'), '0') >=
                                                        NVL(TO_CHAR(xfefecte, 'YYYYMMDD'), '0') THEN
                  xfantigi := xfefecte;
               ELSE
                  xfantigi := xmintras;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  xfantigi := xfefecte;
            END;

            IF xfantigi IS NULL
               OR xaportacions IS NULL THEN
               xestado := 3;
            ELSE
               xestado := 4;
            END IF;

            vtraza := 11;

            UPDATE trasplainout
               SET fantigi = xfantigi,
                   iimpanu = xaportacions,
                   cestado = xestado,
                   iimporte = pimovimi,
                   nnumlin = xnnumlin,
                   fcontab = xfcontab,
                   festado = f_sysdate,
                   nparpla = partis_incorporadas,
                   porcant2007 = v_porcant2007,
                   porcpos2006 = v_porcpos2006,
                   nparant2007 = v_nparant2007,
                   nparpos2006 = v_nparpos2006
             WHERE stras = pstras;
         ELSIF pcextern = 0
               AND pctiptras = 2 THEN
            UPDATE trasplainout
               SET cestado = 4,
                   festado = f_sysdate,
                   iimporte = pimovimi,
                   nnumlin = xnnumlin,
                   nparpla = partis_incorporadas,
                   porcant2007 = v_porcant2007,
                   porcpos2006 = v_porcpos2006,
                   nparant2007 = v_nparant2007,
                   nparpos2006 = v_nparpos2006
             WHERE stras = pstras;
         ELSE
            UPDATE trasplainout
               SET cestado = DECODE(iimpanu, NULL, 3, DECODE(fantigi, NULL, 3, 4)),
                   iimporte = pimovimi,
                   festado = f_sysdate,
                   nnumlin = xnnumlin,
                   nparpla = partis_incorporadas,
                   porcant2007 = v_porcant2007,
                   porcpos2006 = v_porcpos2006,
                   nparant2007 = v_nparant2007,
                   nparpos2006 = v_nparpos2006
             WHERE stras = pstras;
         END IF;
      -- Bug 18851 - RSC - 27/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      END IF;

      vtraza := 12;
      -- FIn Bug 18851
      COMMIT;
      RETURN num_err;
   EXCEPTION
      WHEN errorte THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_in_partic', 97,
                     'psseguro=' || psseguro, num_err);

         IF num_err = 1 THEN
            RETURN 140978;
         ELSE
            RETURN num_err;
         END IF;
      WHEN errorts THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_in_partic', vtraza,
                     'psseguro=' || psseguro, 151255);
         RETURN 151255;
      WHEN errorprimas THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'f_llenar_primas', vtraza, 'psseguro=' || psseguro,
                     151255);
         RETURN 151255;
      WHEN error228 THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'f_llenar_datos', vtraza, 'psseguro=' || psseguro,
                     151255);
         RETURN 151255;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_in_partic', vtraza, SQLCODE, SQLERRM);
         RETURN 140978;
   END f_in_partic;

      /*************************************************************************
      FUNCTION F_IN
        Función que realiza un traspaso de salida.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        3.  PNRIESGO: Tipo numérico. Parámetro de entrada. Número de riesgo.
        4.  PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        5.  PFVALMOV: Tipo fecha. Parámetro de entrada. Fecha de valor del traspaso.
        6.  PFEFECTO: Tipo fecha. Parámetro de entrada. Fecha de efecto del traspaso.
        7.  PIMOVIMI: Tipo numérico. Parámetro de entrada. Importe del traspaso en dinero
        8.  PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.
        9.  PNNUMLIN: Tipo numérico. Parámetro de salida. Clave en CTASEGURO.
        10. PFCONTAB: Tipo numérico. Parámetro de salida. Clave en CTASEGURO.
        11. PNRECIBO: Tipo numérico. Parámetro de salida. Recibo creado.

   Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_in(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcagrpro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN NUMBER,
      psproces IN NUMBER,
      pnnumlin OUT NUMBER,
      pfcontab IN OUT DATE,
      pnrecibo OUT NUMBER)
      RETURN NUMBER IS
      ---
      suplemento     NUMBER;
      dummy          NUMBER;
      cdelega        NUMBER := 9000;
      agente         seguros.cagente%TYPE;   --       agente         NUMBER;   -- Bug 18225 - APD - 11/04/2011 - la precisión de cdelega debe ser NUMBER --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      delegacion     NUMBER;
      psmovagr       NUMBER(8);
      importe        garanseg.icaptot%TYPE;   /*NUMBER(25, 10);   */
      pccobban       seguros.ccobban%TYPE;   --       pccobban       NUMBER(3); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      empresa        seguros.cempres%TYPE;   --       empresa        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      emision        seguros.femisio%TYPE;   --       emision        DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnliqmen       NUMBER;
      smovrecibo     NUMBER;
      num_err        NUMBER;
      num_movimi     NUMBER;
      aux_conta      NUMBER;
      pnorden        garanpro.norden%TYPE;   --       pnorden        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pctarifa       garanpro.ctarifa%TYPE;   --       pctarifa       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcformul       garanpro.cformul%TYPE;   --       pcformul       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pfmovini       DATE;
      participacion  NUMBER;
      v_sproduc      seguros.sproduc%TYPE;
      v_ccalint      ctaseguro.ccalint%TYPE;
      v_cmodcom      NUMBER;
      v_cmultimon    parempresas.nvalpar%TYPE;
      pnnumlinshw    NUMBER;
      pfcontabshw    DATE;
      v_ccalintshw   NUMBER;
      ---
      errorte        EXCEPTION;
      vpasexec       NUMBER := 0;
      vparams        VARCHAR2(500)
         := 'pstras=' || pstras || '-psseguro=' || psseguro || '-pnriesgo=' || pnriesgo
            || '-pcagrpro=' || pcagrpro || '-pfvalmov=' || pfvalmov || '-pfefecto='
            || pfefecto || '-pimovimi=' || pimovimi || '-psproces=' || psproces
            || '-pnnumlin=' || pnnumlin || '-pfcontab=' || pfcontab || '-pnrecibo='
            || pnrecibo;
      vtraza         NUMBER := 0;
   BEGIN
      --Es genera un moviment de traspàs d'entrada
      SELECT (NVL(MAX(nsuplem), 0) + 1)
        INTO suplemento
        FROM movseguro
       WHERE sseguro = psseguro;

      vtraza := 1;
      vpasexec := 1;
      num_err := f_movseguro(psseguro, NULL, 270, 1, pfefecto, NULL, suplemento, 0, NULL,
                             num_movimi);
      vtraza := 2;

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      vpasexec := 2;

      ---Posem la data d'emissió
      UPDATE movseguro
         SET femisio = pfefecto
       WHERE movseguro.sseguro = psseguro
         AND movseguro.nmovimi = num_movimi;

      ---Dupliquem la informació i insertem l'import del traspàs
      ---en la garantia 282
      --JGM: Cpina em diu que ho comentem per evitar conflicte de la data
      --num_err := f_dupgaran(psseguro, pfefecto, num_movimi);
      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      vpasexec := 3;

      BEGIN
         SELECT COUNT(*)
           INTO aux_conta
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = num_movimi
            AND cgarant = 282;

         IF aux_conta = 0 THEN
            SELECT g.norden, g.ctarifa, g.cformul
              INTO pnorden, pctarifa, pcformul
              FROM garanpro g, seguros s
             WHERE g.cramo = s.cramo
               AND g.cmodali = s.cmodali
               AND g.ctipseg = s.ctipseg
               AND g.ccolect = s.ccolect
               AND s.sseguro = psseguro
               AND cgarant = 282;

            vpasexec := 4;
            vtraza := 3;

            ---
            INSERT INTO garanseg
                        (cgarant, sseguro, nriesgo, finiefe, norden, crevali, ctarifa,
                         icapital, precarg, iprianu, iextrap, ffinefe, cformul, ctipfra,
                         ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                         itarifa, nmovimi, itarrea, ipritot, icaptot)
                 VALUES (282, psseguro, 1, pfefecto, pnorden, 4, pctarifa,
                         pimovimi, NULL, 0, NULL, pfefecto + 1, pcformul, NULL,
                         NULL, 0, 0, NULL, 0, NULL, NULL,
                         NULL, num_movimi, NULL, 0, pimovimi);
         ELSE   --- Si ja existeix la garantia 282
            vpasexec := 5;

            UPDATE garanseg
               SET icapital = pimovimi,
                   icaptot = pimovimi
             WHERE sseguro = psseguro
               AND nmovimi = num_movimi
               AND cgarant = 282;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 101959;
            RAISE errorte;
      END;

      vpasexec := 6;

      --**** Creem el rebut
      SELECT ccobban, cempres, cagente, femisio
        INTO pccobban, empresa, agente, emision
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 4;
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(empresa, 'MULTIMONEDA'), 0);   -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
      vpasexec := 7;
      num_err := f_insrecibo(psseguro, agente, f_sysdate, pfvalmov, pfvalmov + 1, 10, NULL,
                             NULL, pccobban, 0, 1, pnrecibo, 'A', NULL, 51, num_movimi,
                             pfefecto);

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      vpasexec := 8;

      IF f_es_renovacion(psseguro) = 0 THEN
         -- es cartera
         v_cmodcom := 2;
      ELSE
         -- si es 1 es nueva produccion
         v_cmodcom := 1;
      END IF;

      vtraza := 5;
      num_err := f_detrecibo(NULL, psseguro, pnrecibo, 10,   -- JLB tipomovimiento 10, porque venimos de un trapaso
                             'A', v_cmodcom, f_sysdate, pfvalmov, NULL, NULL, pimovimi, NULL,
                             num_movimi, NULL, importe);   --pimovimi no pot ser null

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      -- fin Bug 15707 - APD - 14/03/2011

      -- Bug 18851 - RSC - 27/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      UPDATE trasplainout
         SET nrecibo = pnrecibo
       WHERE stras = pstras;

      -- Fin bug 18851

      --Si todo ha ido bien, incluso la documentación enviamos a SAP
           --Bug.: 20923 - 14/01/2012 - ICV
      IF NVL(pac_parametros.f_parempresa_n(empresa, 'GESTIONA_COBPAG'), 0) = 1
         AND num_err = 0 THEN
         num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(empresa, psseguro, num_movimi, 4,
                                                           psproces);
      --Si ha dado error
      --De momento no devolvemos el error
      /*IF num_err <> 0 THEN
        RAISE errorte;
       END IF;*/
      ELSE
         -- Fin bug 18851

         ---Cobrem el rebut
         vpasexec := 9;
         delegacion := f_delegacion(pnrecibo, empresa, agente, emision);
         psmovagr := 0;
         smovrecibo := 0;
         vpasexec := 10;
         vtraza := 6;

         SELECT GREATEST(pfefecto, pfvalmov, f_sysdate)
           INTO pfmovini
           FROM DUAL;

         vpasexec := 11;
         num_err := f_movrecibo(pnrecibo, 1, pfefecto, NULL, smovrecibo, xnliqmen, dummy,
                                pfmovini, pccobban, cdelega, NULL, NULL);
         COMMIT;

         IF num_err <> 0 THEN
            RAISE errorte;
         END IF;

         vpasexec := 12;

         UPDATE recibos
            SET cestimp = 2,
                cbancar = NULL
          WHERE nrecibo = pnrecibo;

         ---**** Modifiquem tipus de moviment, assignem data valor
         ---**** i calculem el nombre de participacions
         -- Bug 15707 - APD - 14/03/2011 - Se elimina esta parte de codigo ya que, en teoria en el modelo Unit Linked,
         -- el calculo del valor liquidativo, si ya está introducido, se hace en la funcion F_MOVCTA_ULK
         /*DECLARE
            pnparpla       NUMBER;
            tdiv           NUMBER;
         BEGIN
            pnparpla := f_valor_participlan(pfvalmov, psseguro, tdiv);

            IF pnparpla <> -1 THEN
               participacion := ROUND((pimovimi / pnparpla), 6);
            ELSE
               participacion := NULL;
            END IF;
         END;*/
         -- Bug 15707 - APD - 14/03/2011 - se busca el sproduc
         vpasexec := 13;

         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         vtraza := 7;
         -- Bug 15707 - APD - 14/03/2011 - En el caso del modelo Unit Linked/Planes se debe buscar el valor
         -- del campo ccalint
         vpasexec := 14;

         -- alberto - Abrimos CTASEGURO con el nrecibo
         -- y hacemos todo el codigo del LOOP para cada aportación
         FOR tr IN (SELECT   sseguro, nnumlin, nrecibo, fcontab
                        FROM ctaseguro
                       WHERE sseguro = psseguro
                         AND nrecibo = pnrecibo
                    ORDER BY nnumlin) LOOP
            pnrecibo := tr.nrecibo;
            pnnumlin := tr.nnumlin;
            pfcontab := tr.fcontab;

            IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 0 THEN
               SELECT nnumlin, fcontab
                 INTO pnnumlin, pfcontab
                 FROM ctaseguro
                WHERE nrecibo = pnrecibo
                  AND nnumlin = tr.nnumlin
                  AND sseguro = psseguro;
            ELSE
               SELECT nnumlin, fcontab, ccalint
                 INTO pnnumlin, pfcontab, v_ccalint
                 FROM ctaseguro
                WHERE nrecibo = pnrecibo
                  AND sseguro = psseguro
                  AND nnumlin = tr.nnumlin
                  AND cesta IS NULL;
            END IF;

            vtraza := 8;
            vpasexec := 15;

            -- Bug 15707 - APD - 14/03/2011 - En el caso del modelo Unit Linked/Planes se debe actualizar
            -- solo los campos cmovimi y fvalmov
            -- En caso contrario, comentar la actualizacion del campo nparpla
            IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 0 THEN
               UPDATE ctaseguro
                  SET cmovimi = 8,
                      fvalmov = pfvalmov,
                      cestpar = 1,
                      fasign = f_sysdate
                WHERE sseguro = psseguro
                  AND fcontab = pfcontab
                  AND nnumlin = pnnumlin;

               -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfcontab,
                                                                        pnnumlin, pfvalmov);

                  IF num_err <> 0 THEN
                     RAISE errorte;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
            ELSE
               UPDATE ctaseguro
                  SET cmovimi = 8,
                      fvalmov = pfvalmov
                WHERE sseguro = psseguro
                  AND fcontab = pfcontab
                  AND nnumlin = pnnumlin
                  AND ccalint = v_ccalint;

               vtraza := 9;

               -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                FROM ctaseguro
                               WHERE sseguro = psseguro
                                 AND fcontab = pfcontab
                                 AND nnumlin = pnnumlin
                                 AND ccalint = v_ccalint) LOOP
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                           reg.fcontab,
                                                                           reg.nnumlin,
                                                                           reg.fvalmov);

                     IF num_err <> 0 THEN
                        RAISE errorte;
                     END IF;
                  END LOOP;
               END IF;

               -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda

               -- Bug 18851 - RSC - 23/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
               UPDATE ctaseguro
                  SET fvalmov = pfvalmov
                WHERE sseguro = psseguro
                  AND cmovimi = 45
                  AND ccalint = v_ccalint;

               -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                FROM ctaseguro
                               WHERE sseguro = psseguro
                                 AND cmovimi = 45
                                 AND ccalint = v_ccalint) LOOP
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                           reg.fcontab,
                                                                           reg.nnumlin,
                                                                           reg.fvalmov);

                     IF num_err <> 0 THEN
                        RAISE errorte;
                     END IF;
                  END LOOP;
               END IF;

               vtraza := 10;
               -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
               num_err := pac_mantenimiento_fondos_finv.f_asign_unidades(pfvalmov, 2, empresa,
                                                                         NULL, psseguro);

               IF num_err <> 0 THEN
                  RAISE errorte;
               END IF;
            -- Fin Bug 18851
            END IF;

            -- alberto, este update lo hacemos aquí en el bucle de ctaseguro
            -- y lo hemos quitado al final de bucle de ctaseguro_shadow
            -- fin Bug 15707 - APD - 14/03/2011
            -- JRH Dejamos al menos una referencia de nnumlin en el traspaso para ques sigan funcionando las funciones de sumas de pPa.
            UPDATE trasplainout
               SET fcontab = pfcontab,
                   nnumlin = pnnumlin
             WHERE stras = pstras;
         END LOOP;

         -- ALBERTO SEGUNDO cursor para el shadow
         FOR tr IN (SELECT   sseguro, nnumlin, nrecibo, fcontab
                        FROM ctaseguro_shadow
                       WHERE sseguro = psseguro
                         AND nrecibo = pnrecibo
                    ORDER BY nnumlin) LOOP
            pnrecibo := tr.nrecibo;
            pnnumlin := tr.nnumlin;
            pfcontab := tr.fcontab;
            vtraza := 11;

            IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
               IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 0 THEN
                  SELECT nnumlin, fcontab
                    INTO pnnumlinshw, pfcontabshw
                    FROM ctaseguro_shadow
                   WHERE nrecibo = pnrecibo
                     AND sseguro = psseguro
                     AND nnumlin = tr.nnumlin;
               ELSE
                  SELECT nnumlin, fcontab, ccalint
                    INTO pnnumlinshw, pfcontabshw, v_ccalintshw
                    FROM ctaseguro_shadow
                   WHERE nrecibo = pnrecibo
                     AND sseguro = psseguro
                     AND cesta IS NULL
                     AND nnumlin = tr.nnumlin;
               END IF;

               vpasexec := 15;

               -- Bug 15707 - APD - 14/03/2011 - En el caso del modelo Unit Linked/Planes se debe actualizar
               -- solo los campos cmovimi y fvalmov
               -- En caso contrario, comentar la actualizacion del campo nparpla
               IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 0 THEN
                  UPDATE ctaseguro_shadow
                     SET cmovimi = 8,
                         fvalmov = pfvalmov,
                         cestpar = 1,
                         fasign = f_sysdate
                   WHERE sseguro = psseguro
                     AND fcontab = pfcontabshw
                     AND nnumlin = pnnumlinshw;

                  -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                               pfcontabshw,
                                                                               pnnumlinshw,
                                                                               pfvalmov);

                     IF num_err <> 0 THEN
                        RAISE errorte;
                     END IF;
                  END IF;
               -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
               ELSE
                  UPDATE ctaseguro_shadow
                     SET cmovimi = 8,
                         fvalmov = pfvalmov
                   WHERE sseguro = psseguro
                     AND fcontab = pfcontabshw
                     AND nnumlin = pnnumlinshw
                     AND ccalint = v_ccalintshw;

                  -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro_shadow
                                  WHERE sseguro = psseguro
                                    AND fcontab = pfcontabshw
                                    AND nnumlin = pnnumlinshw
                                    AND ccalint = v_ccalintshw) LOOP
                        num_err :=
                           pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                          reg.fcontab,
                                                                          reg.nnumlin,
                                                                          reg.fvalmov);

                        IF num_err <> 0 THEN
                           RAISE errorte;
                        END IF;
                     END LOOP;
                  END IF;

                  vtraza := 12;

                  -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda

                  -- Bug 18851 - RSC - 23/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
                  UPDATE ctaseguro_shadow
                     SET fvalmov = pfvalmov
                   WHERE sseguro = psseguro
                     AND cmovimi = 45
                     AND ccalint = v_ccalintshw;

                  -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro_shadow
                                  WHERE sseguro = psseguro
                                    AND cmovimi = 45
                                    AND ccalint = v_ccalintshw) LOOP
                        num_err :=
                           pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                          reg.fcontab,
                                                                          reg.nnumlin,
                                                                          reg.fvalmov);

                        IF num_err <> 0 THEN
                           RAISE errorte;
                        END IF;
                     END LOOP;
                  END IF;

                  -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
                  num_err := pac_mantenimiento_fondos_finv.f_asign_unidades_shw(pfvalmov, 2,
                                                                                empresa, NULL,
                                                                                psseguro);

                  IF num_err <> 0 THEN
                     RAISE errorte;
                  END IF;
               -- Fin Bug 18851
               END IF;
            END IF;

            vpasexec := 16;
         END LOOP;
      -- FIN LOOP ALBERTO TRASPLAAPORTACIONES
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN errorte THEN
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_in - errorte', vpasexec, vparams,
                     num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_in - others', vpasexec, vparams,
                     num_err);
         RETURN SQLCODE;
   END f_in;

      /*************************************************************************
      FUNCTION F_OUT
       Función que realiza un traspaso de salida.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PCTIPTRAS: Tipo numérico. Parámetro de entrada. Tipo de traspaso Total o parcial
        3.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        4.  PNRIESGO: Tipo numérico. Parámetro de entrada. Número de riesgo.
        5.  PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        6.  PFVALMOV: Tipo fecha. Parámetro de entrada/salida. Fecha de valor del traspaso.
        7.  PFEFECTO: Tipo fecha. Parámetro de entrada/salida. Fecha de efecto del traspaso.
        8.  PIMOVIMI: Tipo numérico. Parámetro de entrada/salida. Importe del traspaso en dinero.
        9.  PPARTRAS: Tipo numérico. Parámetro de entrada/salida. Importe del traspaso en participaciones.
        10. PSPERSDESTIN: Tipo numérico. Parámetro de entrada. Destinatario del pago.
        11. PEPAGSIN: Tipo numérico. Parámetro de entrada. Estado del pago del siniestro aceptado o pagado
        12. PCBANCAR: Tipo carácter. Parámetro de entrada.Cuenta bancaria destino del pago.
        13. PCTIBBAN: Tipo numérico. Parámetro de entrada. Tipo de cuenta.
        14. PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.
        15. PNNUMLIN: Tipo numérico. Parámetro de salida. Clave en CTASEGURO.
        16. PFCONTAB: Tipo numérico. Parámetro de salida. Clave en CTASEGURO.

   Retorna un valor numérico: 0 si ha demorado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_out(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcagrpro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pspersdestin IN NUMBER,
      pepagsin IN NUMBER,
      pcbancar IN VARCHAR2,
      pctibban IN NUMBER,
      psproces IN NUMBER,
      pnnumlin OUT NUMBER,
      pfcontab OUT DATE)
      RETURN NUMBER IS
      ---
      num_err        NUMBER := 0;
      xproces        NUMBER;
      xmotivo        NUMBER;
      xgaran         parproductos.cvalpar%TYPE;   --       xgaran         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xproduc        seguros.sproduc%TYPE;   --       xproduc        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xcactivi       seguros.cactivi%TYPE;   --       xcactivi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      errorts        EXCEPTION;
      --
      suplemento     NUMBER;
      num_movimi     NUMBER;
      xnsinies       trasplainout.nsinies%TYPE;   --       xnsinies       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xsidepag       pagosini.sidepag%TYPE;   --       xsidepag       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xpago          pagosini.isinret%TYPE;   --       xpago          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ximovimi       ctaseguro.imovimi%TYPE;
      ximovim2       ctaseguro.imovim2%TYPE;
      xspersdestin   NUMBER(10);
      vivalora       sin_tramita_reserva.ireserva%TYPE;
      vipenali       sin_tramita_reserva.ipenali%TYPE;
      vicapris       sin_tramita_reserva.icaprie%TYPE;
      v_nmovres      NUMBER;
      v_sproces      procesoscab.sproces%TYPE;
      v_nmovpag      sin_tramita_movpago.nmovpag%TYPE;
      v_cempres      seguros.cempres%TYPE;
      vcramo         seguros.cramo%TYPE;
      vsinterf       NUMBER;
      vifranq        sin_tramita_reserva.ifranq%TYPE;   --27059:NSS:05/06/2013
      vtraza         NUMBER := 0;
   BEGIN
--------------------------- JGM: 1.  Si psproces no viene informado crear proceso
      IF psproces IS NULL THEN
         num_err := f_procesini(f_user, f_empres, 'TRASPASO', 'Traspaso de salida', xproces);
      ELSE
         --JGM Cal? error := f_proceslin(v_sproces, 'Inicio proceso Revision/Renovacion '|| TO_CHAR (f_sysdate, 'DD-MM-YYYY  HH24:MI'), 1, nprolin, 4);
         xproces := psproces;
      END IF;

      IF num_err <> 0 THEN
         RAISE errorts;
      END IF;

      vtraza := 1;

--------------------------- JGM: 2. Recuperación del motivo y de la garantía a asignar al traspaso
      BEGIN
         SELECT p.cvalpar, s.sproduc, s.cactivi, s.cempres, s.cramo
           INTO xgaran, xproduc, xcactivi, v_cempres, vcramo
           FROM parproductos p, seguros s
          WHERE p.sproduc = s.sproduc
            AND p.cparpro = 'GARTRAS_OUT'
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := -1;
            RAISE errorts;
      END;

      vtraza := 2;

      -- Bug 19425/94998 - RSC - 20/10/2011 - CIV998-Activar la nova gestio de traspassos
      -- Modelo antiguo de siniestros
      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
         num_err := pac_sin.f_inicializar_siniestro(psseguro, pnriesgo, pfefecto, pfefecto,
                                                    f_axis_literales(109232, f_idiomauser), 8,
                                                    pctiptras, 21, xnsinies, xgaran);

         UPDATE trasplainout
            SET nsinies = xnsinies
          WHERE stras = pstras;

         vtraza := 3;
         num_err := pk_cal_sini.valo_pagos_sini(pfefecto, psseguro, xnsinies, xproduc,
                                                xcactivi, 6, 8, pctiptras, pfefecto, vivalora,
                                                vipenali, vicapris);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vtraza := 4;
         num_err := pac_sin_insert.f_insert_valoraciones(xnsinies, 6, pfefecto, vivalora,
                                                         vipenali, vicapris);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF pspersdestin IS NULL THEN
            NULL;
         ELSE
            xspersdestin := pspersdestin;
         END IF;

         vtraza := 5;
         num_err := pac_sin_insert.f_insert_destinatario(xnsinies, xspersdestin, psseguro,
                                                         pnriesgo, NULL, 5, 1, NULL, NULL,
                                                         pcbancar, NULL, pctibban);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vtraza := 6;
         num_err := pk_cal_sini.gen_pag_sini(pfefecto, psseguro, xnsinies, xproduc, xcactivi,
                                             8, pctiptras, pfefecto);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vtraza := 7;
         num_err := pk_cal_sini.insertar_pagos(xnsinies);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         SELECT sidepag, isinret
           INTO xsidepag, xpago
           FROM pagosini
          WHERE nsinies = xnsinies;

         vtraza := 8;

         -- Lo generamos ya pagado. Lo vamos a pagar inmmediatametne
         UPDATE pagosini
            SET cestpag = 2
          WHERE sidepag = xsidepag;
      ELSE
         -- Fin Bug 19425/94998

         --------------------------- JGM:4.  Creación del cabecera del siniestro.
         /*
          La causa y motivo del siniestro son diferentes si el traspaso total o parcial.
          En descripción del siniestro colocaremos la descripción de un literal que será fijo.
          También se crean la tramitación, sus movimientos y se inicia la reserva:

          fsinies -- Desde traspasos se llamará con la fecha de efecto del traspaso
         */
         num_err :=
            pac_call.f_apertura_siniestro
                               (xproduc, psseguro, pnriesgo, xcactivi, pfefecto, pfefecto,   -- <--pfnotifi
                                8,   -- <--pccausin
                                pctiptras, NULL,   -- <--ptsinies -- descripción de un literal que será fijo
                                NULL,   -- <--ptzonaocu
                                xgaran, NULL,   -- <--pitraspaso
                                xnsinies);

         UPDATE trasplainout
            SET nsinies = xnsinies
          WHERE stras = pstras;

         vtraza := 9;
         --------------------------- JGM 4bis: Llamada a la formulación para el cálculo de importes (NUEVO!!!)
         num_err := pac_sin_formula.f_cal_valora(pfefecto, psseguro, pnriesgo, xnsinies, 0, 0,
                                                 xproduc, xcactivi, 6, 8, pctiptras, pfefecto,
                                                 pfefecto, NULL, NULL, vivalora, vipenali,
                                                 vicapris, vifranq   --27059:NSS:05/06/2013
                                                                  );

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- Se inserta la reserva
         num_err :=
            pac_siniestros.f_ins_reserva
               (xnsinies, 0, 1, 6, 1, pfefecto, NULL,   -- BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en función
                                                        -- de si es multimoneda o no
                NVL(vivalora, 0) - NVL(vipenali, 0), NULL, vicapris, vipenali, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, v_nmovres,
                1   --cmovres --Bug 31294/174788:NSS:22/05/2014
                 );
         vtraza := 10;

         --------------------------- JGM: 5. Insertamos el destinatario. El destinatario es la compañía aseguradora o fondo de pensiones destino.
         --  pctipdes -- >
         --  pcpagdes -- >
         IF pspersdestin IS NULL THEN
            NULL;
         -----error
         -----xspersdestin := 112336;   -- JGM: LA PERSONA ES NULA SI ME INVENTO EL PLAN EN TRASPLAINOUT, que pasa si es por CCOMPANI???
         ELSE
            xspersdestin := pspersdestin;
         END IF;

         num_err :=
            pac_siniestros.f_ins_destinatario
                                           (xnsinies, 0,   --v_ntramit,
                                            xspersdestin, pcbancar, pctibban, 100,   --Valor donat per CPINA
                                            NULL, 5,   --pctipdes (em diu cpina que de 1 el passem a 5),
                                            1,   --pcpagdes,
                                            NULL);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vtraza := 11;
         --------------------------- JGM: 6. Insertamos el pago del siniestro

         -- Generamos los pagos
         num_err := pac_sin_formula.f_genera_pago(psseguro, pnriesgo,
                                                  -- Bug 16219. FAL. 06/10/2010. Parametrizar que la generación del pago sea por garantia
                                                  xgaran,
                                                  -- Fi Bug 16219
                                                  xproduc, xcactivi, xnsinies, 0, 8, pctiptras,
                                                  pfefecto, pfefecto);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := pac_sin_formula.f_inserta_pago(xnsinies, 0, 1, 6, xsidepag, xpago,
                                                   pctibban, pcbancar);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      vtraza := 12;
      pimovimi := xpago;
      -- ini Bug 0018536 - JMF - 13/05/2011
      num_err := f_traspaso_tmp_primas_cons(psseguro, NULL, xnsinies);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- fin Bug 0018536 - JMF - 13/05/2011

      -- Bug 18851 - RSC - 22/06/2011 - ENSA102 - Parametrización básica de traspasos de Contribución definida
      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'GESTIONA_COBPAG'), 0) = 1 THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 1 THEN
            num_err := pac_siniestros.f_ins_movpago(xsidepag, 1, pfefecto, 1, NULL, v_sproces,
                                                    0, v_nmovpag /*txema--<*/, 0,
                                                    0 /*>--txema*/);
            vtraza := 13;

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            --Bug.: 21234 - ICV - 07/02/2012
            num_err := pac_siniestros.f_gestiona_cobpag(xsidepag, v_nmovpag, 1, pfefecto, NULL,
                                                        vsinterf);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         --Fi bug.: 21234
         END IF;
      ELSE
         -- Fin bug 18851
         IF xsidepag IS NOT NULL THEN
            IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
               num_err := pac_sin.f_finalizar_sini(xnsinies, 1, '1005', TRUNC(f_sysdate),
                                                   100832, f_idiomauser);
               vtraza := 14;

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            ELSE
               num_err := pac_call.f_pago_i_cierre_sin(xnsinies, xproduc, xcactivi, xsidepag);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            BEGIN
               SELECT nnumlin, fcontab
                 INTO pnnumlin, pfcontab
                 FROM ctaseguro
                WHERE cmovimi = 47
                  AND nsinies = xnsinies
                  AND sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN SQLCODE;
            END;
         END IF;
      END IF;

      vtraza := 15;
      RETURN 0;
   EXCEPTION
      WHEN errorts THEN
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_out - errorts', 98,
                     'psseguro=' || psseguro, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_out - others', 99,
                     'psseguro=' || psseguro || '-error=' || SQLCODE, SQLERRM);
         RETURN 1;
   END f_out;

      /*************************************************************************
      FUNCTION F_TRASPASO_INVERSO
       Función que realiza un traspaso de salida.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PSSEGURO_DS: Tipo numérico. Parámetro de entrada. Identificador de la póliza destino.
        3.  PNRIESGO_DS: Tipo numérico. Parámetro de entrada. Núm. del riesgo.
        4.  PSSEGURO_OR: Tipo numérico. Parámetro de entrada. Identificador de la póliza origen.
        5.  PNRIESGO_OR: Tipo numérico. Parámetro de entrada. Núm. del riesgo.
        6.  PIMOVIMI: Tipo numérico. Parámetro de entrada/salida. Importe del traspaso en dinero.
        7.  PPARTRAS: Tipo numérico. Parámetro de entrada/salida. Importe del traspaso en participaciones.
        8.  PCTIPTRAS: Tipo numérico. Parámetro de entrada. Tipo de traspaso Total o parcial
        9.  PCINOUT: Tipo numérico. Parámetro de entrada. Sentido del traspaso que se crea.
        10. PSTRASIN: Tipo numérico. Parámetro de entrada/salida. Identificador del traspaso inverso creado.
        11. PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.

   Retorna un valor numérico: 0 si ha insertado el traspaso inverso o un código identificativo de error si se ha producido algún problema.
       *************************************************************************/
   FUNCTION f_traspaso_inverso(
      pstras IN NUMBER,
      psseguro_ds IN NUMBER,
      pnriesgo_ds IN NUMBER,
      psseguro_or IN NUMBER,
      pnriesgo_or IN NUMBER,
      pctipder IN NUMBER,
      pimovimi IN OUT NUMBER,
      pnporcen IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pctiptras IN NUMBER,
      pctiptrassol IN NUMBER,
      pcinout IN NUMBER,
      pstrasin IN OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      id_traspaso    trasplainout.stras%TYPE;   --       id_traspaso    NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ccodpla      NUMBER(7);
      pnpoliza       seguros.npoliza%TYPE;   --       pnpoliza       NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pncertif       seguros.ncertif%TYPE;   --       pncertif       NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xcoment        VARCHAR2(100);
      pcbancar       VARCHAR2(30);
      pctipban       NUMBER(1);
      ptcompani      VARCHAR2(40);
      ptnompla       VARCHAR2(60);
      v_cagrpro      seguros.cagrpro%TYPE;
      reg_trasp      trasplainout%ROWTYPE;   --JRH IMP
   BEGIN
      SELECT proplapen.ccodpla, npoliza, ncertif, seguros.cagrpro
        INTO v_ccodpla, pnpoliza, pncertif, v_cagrpro
        FROM proplapen, productos, seguros
       WHERE seguros.sseguro = DECODE(pcinout, 1, psseguro_or, psseguro_ds)
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND productos.sproduc = proplapen.sproduc;

      IF v_cagrpro = 2 THEN
         --COMPANYIA
         SELECT SUBSTR(f_nombre(a.sperson, 1), 1, 40), rel.ctipban, rel.cbancar
           INTO ptcompani, pctipban, pcbancar
           FROM aseguradoras a, relasegdep rel
          WHERE a.ccodaseg = rel.ccodaseg(+)
            AND rel.ctrasp(+) = 1
            AND a.ccodaseg = v_ccodpla;
      ELSIF v_cagrpro = 11 THEN
         --PP
         SELECT SUBSTR(p.tnompla, 1, 60), rel.ctipban, rel.cbancar
           INTO ptnompla, pctipban, pcbancar
           FROM planpensiones p, fonpensiones f, relfondep rel
          WHERE p.ccodfon = f.ccodfon
            AND rel.ccodfon(+) = f.ccodfon
            AND rel.ctrasp(+) = 1
            AND p.ccodpla = v_ccodpla;
      ELSE
         -- ERROR
         RETURN 1;
      END IF;

      xcoment := f_axis_literales(111334);

      SELECT *
        INTO reg_trasp
        FROM trasplainout
       WHERE stras = pstras;   --JRH IMP hemos de indicar el fvalor en el trasaso inverso

      --IF pcparoben = 1 THEN --JGM: Y ESTO????
      SELECT stras.NEXTVAL
        INTO id_traspaso
        FROM DUAL;

      INSERT INTO trasplainout
                  (stras, cinout, sseguro,
                   ctipder, fsolici, ccodpla,
                   ccompani, tcompani, tpolext, ncertext,
                   cestado, ctiptras, ctiptrassol, iimptemp, fantigi, nporcen, nparpla, tmemo,
                   stras_parent, ctipban, cbancar, cexterno, festado, fvalor)
           VALUES (id_traspaso, pcinout, DECODE(pcinout, 1, psseguro_ds, psseguro_or),
                   pctipder, f_sysdate, DECODE(v_cagrpro, 2, NULL, 11, v_ccodpla),
                   DECODE(v_cagrpro, 11, NULL, 2, v_ccodpla), ptcompani, pnpoliza, pncertif,
                   2, pctiptras, pctiptrassol, pimovimi, NULL, pnporcen, 0, xcoment,
                   pstras, pctipban, pcbancar, 0, f_sysdate, reg_trasp.fvalor);

      pstrasin := id_traspaso;

      -- alberto - llenamos primas consumidas Y llenar_datos_228 en traspaso interno
      IF pcinout = 1 THEN
         num_err := f_llenar_primas(pstras, pstrasin);

         IF num_err <> 0 THEN
            RETURN 2;
         END IF;

         num_err := f_llenar_datos_228(pstras, pstrasin);

         IF num_err <> 0 THEN
            RETURN 3;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_traspaso_inverso', 99, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_traspaso_inverso;

      /*************************************************************************
      FUNCTION F_INFORMAR_TRASPASO
       Función que sirve para informar los datos fiscales (aportaciones del año, porcentaje aportaciones 2007, fecha de antigüedad …). Sólo se puede utilizar si el traspaso está en estado 3-Pendientes de informar.

        1.  PSTRAS:  Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  FANTIGI: Tipo fecha. Parámetro de entrada. Fecha de antigüedad.
        3.  IIMPANU: Tipo numérico. Parámetro de entrada. Aportaciones del año de traspaso en el plan origen.
        4.  NPARRET: Tipo numérico. Parámetro de entrada. Participaciones retenidas para contingencias posteriores.
        5.  TMEMO:   Tipo varchar. Parametro de entrada. Observaciones.
        6.  IIMPRET: Tipo numérico. Parámetro de entrada. Importe retenido para contingencias posteriores a la primera contingencia.
        7.  NPARPOS2006: Tipo numérico. Parámetro de entrada. Participaciones posteriores al año 2006.
        8.  PORCPOS2006: Tipo numérico. Parámetro de entrada. Porcentaje de las participaciones posteriroes al año 2006.
        9.  NPARANT2007: Tipo numérico. Parámetro de entrada. Participaciones anteriores al año 2007.
       10.  PORCANT2007: Tipo numérico. Parámetro de entrada. Porcentaje de participaciones anteriores al año 2007.

   Retorna un valor numérico: 0 si ha informado el traspaso o un código de error identificativo.
       *************************************************************************/
   FUNCTION f_informar_traspaso(
      pstras IN NUMBER,
      zfantigi IN DATE,
      ziimpanu IN NUMBER,
      znparret IN NUMBER,
      ziimpret IN NUMBER,
      ztmemo IN VARCHAR2,   -- BUG 15197 - PFA - Afegir camp observacions
      znparpos2006 IN NUMBER,
      zporcpos2006 IN NUMBER,
      znparant2007 IN NUMBER,
      zporcant2007 IN NUMBER)
      RETURN NUMBER IS
      vestado        trasplainout.cestado%TYPE;   --       vestado        NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_estado_final trasplainout.cestado%TYPE := 4;   --       v_estado_final NUMBER(1) := 4; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      SELECT cestado
        INTO vestado
        FROM trasplainout
       WHERE stras = pstras;

      IF ziimpanu IS NULL
         OR   --Solo cambio el estado si el usuario informa AMBOS valores
           zfantigi IS NULL THEN
         v_estado_final := vestado;
      END IF;

      IF vestado = 3 THEN
         UPDATE trasplainout
            SET cestado = v_estado_final,
                festado = DECODE(v_estado_final, 4, f_sysdate, festado),
                fantigi = zfantigi,
                iimpanu = ziimpanu,
                nparret = znparret,
                iimpret = ziimpret,
                tmemo = ztmemo,   -- BUG 15197 - PFA - Afegir camp observacions
                nparpos2006 = znparpos2006,
                porcpos2006 = zporcpos2006,
                nparant2007 = znparant2007,
                porcant2007 = zporcant2007
          WHERE stras = pstras;

         COMMIT;
         RETURN 0;
      ELSE
         RETURN -1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_traspasos.f_informar_traspaso', 99, SQLCODE,
                     SQLERRM);
         RETURN -2;
   END f_informar_traspaso;

/* BUG 15372 - 14/07/2010 - SRA - se crea la nueva transacción f_get_traspasos_pol para que informe el bloque Traspasos en axisctr097 */
   FUNCTION f_get_traspasos_pol(
      psseguro IN seguros.sseguro%TYPE,
      pmodo IN VARCHAR2,
      pcerror OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(4000);
      buscar         VARCHAR2(4000);
   BEGIN
      buscar := ' AND s.sseguro = ' || psseguro;

      IF pmodo = 'ANUL_SOL_TRASPAS' THEN
         buscar := buscar || ' and traspaso.cestado IN (3)';
      ELSIF pmodo = 'REVOCACIO_TRAS_EXT' THEN
         buscar := buscar || ' and traspaso.cestado IN (2, 3, 8)';
      ELSIF pmodo LIKE 'TR%' THEN
         buscar := buscar || ' and traspaso.cestado IN (1, 2, 6) and traspaso.stras <> '
                   || SUBSTR(pmodo, 3);
      END IF;

      squery :=
         'select
               traspaso.stras,
               s.sseguro,
               null,'
         ||   --s.nriesgo,
           's.npoliza, s.ncertif,
               s.sproduc,
               null,' ||   --traspaso.cagrpro,
                        'null,' ||   --traspaso.sperstom,
                                  'null,'
         ||   --traspaso.nniftom,
           'PAC_IAX_LISTVALORES.F_Get_NameTomador(s.sseguro,1),' ||   --traspaso.tnomtom,
                                                                   'null,' ||   --traspaso.spersase,
                                                                             'null,'
         ||   --traspaso.nnifase,
           'null,
               traspaso.fsolici, traspaso.cinout,'
         || 'FF_DESVALORFIJO(679,f_usu_idioma,traspaso.cinout) ,' || 'traspaso.ctiptras, '
         || 'FF_DESVALORFIJO(676,f_usu_idioma,traspaso.ctiptras) ,'
         || 'traspaso.cexterno,
               null,' ||   --traspaso.textern,
                        'traspaso.ctipder,
               null,' ||   --traspaso.tctipder,
                        'traspaso.cestado, '
         || 'FF_DESVALORFIJO(675,f_usu_idioma,traspaso.cestado) ,'
         || 'traspaso.ctiptrassol,
               FF_DESVALORFIJO(330,f_usu_idioma,traspaso.ctiptrassol),'
         ||   --traspaso.tctiptrassol,
           'traspaso.iimptemp,
               traspaso.nporcen, traspaso.nparpla, traspaso.iimporte, traspaso.fvalor,
               null,'
         ||   --traspaso.fefecto,
           'traspaso.nnumlin,
               null,'
         ||   --traspaso.fcontab,
           'traspaso.ccodpla,
               traspaso.tcodpla, traspaso.ccompani, traspaso.tcompani, traspaso.ctipban,
               traspaso.cbancar, traspaso.tpolext, traspaso.ncertext,
               null,'
         ||   --traspaso.ssegext,

           --traspaso.planp,
         'traspaso.fantigi, traspaso.iimpanu, traspaso.nparret,
               traspaso.iimpret, traspaso.nsinies, traspaso.nparpos2006, traspaso.porcpos2006,
               traspaso.nparant2007 , traspaso.porcant2007, traspaso.tmemo,traspaso.srefc234, traspaso.cenvio, '
         || 'FF_DESVALORFIJO(331,f_usu_idioma,traspaso.cenvio)'
         || ' from seguros s, trasplainout traspaso where s.sseguro = traspaso.sseguro '
         || buscar || ' order by traspaso.stras';

      IF cur%ISOPEN THEN
         CLOSE cur;
      END IF;

      OPEN cur FOR squery;

      RETURN cur;
   -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
   END f_get_traspasos_pol;

   -- BUG 15296 - 06/07/2010 - SRA: función para obtener el listado de traspasos
   FUNCTION f_obtener_traspasos(
      pfdesde IN DATE,
      pfhasta IN DATE,
      pcempres IN NUMBER,
      pfichero OUT VARCHAR2)
      RETURN NUMBER IS
      v_tfdesde      VARCHAR2(8);
      v_tfhasta      VARCHAR2(8);
      v_nresult      NUMBER := 0;
      v_tobjeto      tab_error.tobjeto%TYPE := 'pac_traspasos.f_obtener_traspasos';
      v_npasexec     tab_error.ntraza%TYPE := 0;
      v_tparam       VARCHAR2(1000)
         := 'pfdesde: ' || TO_CHAR(pfdesde, 'DD/MM/YYYY') || ', pfhasta: '
            || TO_CHAR(pfhasta, 'DD/MM/YYYY');
   BEGIN
      v_npasexec := 1;
      v_tfdesde := TO_CHAR(pfdesde, 'DDMMYYYY');
      v_npasexec := 2;
      v_tfhasta := TO_CHAR(pfhasta, 'DDMMYYYY');
      v_npasexec := 3;
      v_nresult := pac_map.f_extraccion(p_cmapead => '374',
                                        p_linea => pcempres || '|' || v_tfdesde || '|'
                                         || v_tfhasta,
                                        p_fich_out => pfichero);

      IF v_nresult != 0 THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_npasexec, v_tparam, v_nresult);
         RETURN 1;
      END IF;

      v_npasexec := 4;
      RETURN v_nresult;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_npasexec, v_tparam, SQLERRM);
         RETURN 1;
   END f_obtener_traspasos;

-- Bug 16259 - SRA - 18/10/2010: recuperamos en la consulta los campos de "contingencia acaecida" y "fecha de contingencia"
   /*************************************************************************
   FUNCTION F_GET_TRASPLAPRESTA
   Función que sirve para recuperar información de la prestación en caso de traspaso de derechos económicos.
        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  NUM_ERR: Tipo numérico. Parámetro de Salida. 0 si todo ha ido correcto y sino código identificativo de error.
    *************************************************************************/
   FUNCTION f_get_trasplapresta(pstras IN NUMBER, num_err OUT NUMBER)
      RETURN sys_refcursor IS
      vcur           sys_refcursor;
      vquery         VARCHAR2(5000);
      v_npasexec     tab_error.ntraza%TYPE := 0;
   BEGIN
      IF pstras IS NULL THEN
         v_npasexec := 1;
         num_err := -1;
         RETURN NULL;
      ELSE
         v_npasexec := 2;
         vquery :=
            'SELECT stras, npresta, sperson, ctipcap, ctipimp, importe, npartot, impultab, impminrf, indbenef, '
            || 'indpos06, porpos06, fpropag, fultpag, cperiod, creval, ctiprev, fprorev, prevalo, irevalo, '
            || 'nrevanu, cbancar, ctipban, nsinies ' || 'FROM trasplapresta '
            || 'WHERE stras = ' || pstras;
         v_npasexec := 3;

         OPEN vcur FOR vquery;

         num_err := 0;
         v_npasexec := 4;
         RETURN vcur;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF vcur%ISOPEN THEN
            CLOSE vcur;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_TRASPASOS.f_get_trasplapresta', v_npasexec,
                     'pstras: ' || pstras, SQLCODE || ' - ' || SQLERRM);
         num_err := SQLCODE;
         RETURN NULL;
   END f_get_trasplapresta;

   /********* ALBERTO ****************
   Llena la talba de aportaciones TRASPLAAPORTACIONES de un traspaso destino "ptrasout"
   a partir de la tabla PRIMAS_CONSUMIDAS del siniestro de su traspaso origen "ptrasfin"
   **********************************************/
   FUNCTION f_llenar_primas(ptrasfin IN NUMBER, ptrasout IN NUMBER)
      RETURN NUMBER IS
      siniestros     NUMBER;
      numreg         NUMBER := 0;
      v_npasexec     tab_error.ntraza%TYPE := 0;
      importe        NUMBER;
      importepost    NUMBER;
      importeant     NUMBER;
      pctipder       NUMBER;
      pctipapor      NUMBER;
      reg_trasp      trasplainout%ROWTYPE;
   BEGIN
      -- 1- Borraremos la información de TRASAAPORTACIONES  para PtrasOut.
      DELETE      trasplaaportaciones
            WHERE stras = ptrasout;

      IF ptrasfin = ptrasout THEN   --JRH Hacemos los cálculos porque estamos iniciando un traspaso de salida y se debe calcular todo
         /*
         a- Las aportaciones con FECHA anterior a 01/01/2016 se deberán agrupar
         (sumar sus dos campos ipricons y ircm_neto) en una única aportación con fecha 31/12/2015, pero con dos partes diferenciadas en el mismo registro:
             a.   Sumar por un lado los valores de ipricons   y ircm_neto para
             las aportaciones con campo FECHA posterior al 01/01/2007
             (irán en el campo IMPORTE_POST de la tabla TRASPLA_APORT).
             b.   Sumar por un lado los valores de los valores de ipricons
             y ircm_neto para las aportaciones con campo FECHA anterior al 01/01/2007
             (irán en el campo IMPORTE_ANT de la tabla TRASPLA_APORT).
             c.   En este caso no tendremos nnumlin pero si un valor FECHA
             igual al indicado 31/12/2015 para este único registro.
         */
         SELECT SUM(ipricons) + SUM(ircm_neto)
           INTO importe
           FROM primas_consumidas
          WHERE nsinies IN(SELECT nsinies
                             FROM trasplainout
                            WHERE stras = ptrasfin)
            AND TO_CHAR(fecha, 'YYYYMMDD') < '20160101';

         SELECT DECODE(ctipder, 1, 1, 2, 3, 3, 2)
           INTO pctipder
           FROM trasplainout
          WHERE stras = ptrasout;

         IF importe > 0 THEN
            SELECT SUM(ipricons) + SUM(ircm_neto)
              INTO importepost
              FROM primas_consumidas p, ctaseguro c
             WHERE p.nsinies IN(SELECT nsinies
                                  FROM trasplainout
                                 WHERE stras = ptrasfin)
               AND TO_CHAR(p.fecha, 'YYYYMMDD') >= '20070101'
               AND TO_CHAR(p.fecha, 'YYYYMMDD') < '20160101'
               AND c.sseguro = p.sseguro
               AND c.nnumlin = p.nnumlin
               AND c.ctipapor = 'PR';

            SELECT SUM(ipricons) + SUM(ircm_neto)
              INTO importeant
              FROM primas_consumidas p, ctaseguro c
             WHERE p.nsinies IN(SELECT nsinies
                                  FROM trasplainout
                                 WHERE stras = ptrasfin)
               AND TO_CHAR(p.fecha, 'YYYYMMDD') < '20070101'
               AND c.sseguro = p.sseguro
               AND c.nnumlin = p.nnumlin
               AND c.ctipapor = 'PR';

            IF NVL(importeant, 0) <> 0
               OR NVL(importepost, 0) <> 0 THEN
               -- JRH Preguntar a CIV porque las anteriores a 2016 como van si se agrupan?
               --, y las primeras en teoría se deben agrupar aunque de momento no lo hacemos
               --por esto mismo. DE MOMENTO PONEMOS EN CPROCEDENCIA UN 1
               numreg := numreg + 1;

               INSERT INTO trasplaaportaciones
                           (stras, naporta, faporta, cprocedencia,
                            ctipoderecho, importe_post, importe_ant)
                    VALUES (ptrasout, numreg, TO_DATE('31/12/2015', 'dd/mm/yyyy'), 2,
                            pctipder, NVL(importepost, 0), NVL(importeant, 0));
            END IF;

            importepost := 0;
            importeant := 0;

            SELECT SUM(ipricons) + SUM(ircm_neto)
              INTO importepost
              FROM primas_consumidas p, ctaseguro c
             WHERE p.nsinies IN(SELECT nsinies
                                  FROM trasplainout
                                 WHERE stras = ptrasfin)
               AND TO_CHAR(p.fecha, 'YYYYMMDD') >= '20070101'
               AND TO_CHAR(p.fecha, 'YYYYMMDD') < '20160101'
               AND c.sseguro = p.sseguro
               AND c.nnumlin = p.nnumlin
               AND NVL(c.ctipapor, 'A') <> 'PR';

            SELECT SUM(ipricons) + SUM(ircm_neto)
              INTO importeant
              FROM primas_consumidas p, ctaseguro c
             WHERE p.nsinies IN(SELECT nsinies
                                  FROM trasplainout
                                 WHERE stras = ptrasfin)
               AND TO_CHAR(p.fecha, 'YYYYMMDD') < '20070101'
               AND c.sseguro = p.sseguro
               AND c.nnumlin = p.nnumlin
               AND NVL(c.ctipapor, 'A') <> 'PR';

            -- JRH Preguntar a CIV porque las anteriores a 2016 como van si se agrupan?
            --, y las primeras en teoría se deben agrupar aunque de momento no lo hacemos
            --por esto mismo. DE MOMENTO PONEMOS EN CPROCEDENCIA UN 1
            IF NVL(importeant, 0) <> 0
               OR NVL(importepost, 0) <> 0 THEN
               -- JRH Preguntar a CIV porque las anteriores a 2016 como van si se agrupan?
               --, y las primeras en teoría se deben agrupar aunque de momento no lo hacemos
               --por esto mismo. DE MOMENTO PONEMOS EN CPROCEDENCIA UN 1
               numreg := numreg + 1;

               INSERT INTO trasplaaportaciones
                           (stras, naporta, faporta, cprocedencia,
                            ctipoderecho, importe_post, importe_ant)
                    VALUES (ptrasout, numreg, TO_DATE('31/12/2015', 'dd/mm/yyyy'), 1,
                            pctipder, NVL(importepost, 0), NVL(importeant, 0));
            END IF;
         END IF;

         -- b- Las aportaciones con FECHA a partir de 01/01/2016
         FOR reg IN (SELECT   SUM(p.ipricons) ipricons, SUM(p.ircm_neto) ircm_neto,
                              TRUNC(p.fecha) fecha,
                                                   --, nnumlin,
                                                   p.sseguro,
                              DECODE(c.ctipapor, 'PR', 'PR', NULL) ctipapor
                         FROM primas_consumidas p, ctaseguro c
                        WHERE p.sseguro = c.sseguro
                          AND p.nnumlin = c.nnumlin
                          AND p.nsinies IN(SELECT nsinies
                                             FROM trasplainout
                                            WHERE stras = ptrasfin)
                          AND TO_CHAR(p.fecha, 'YYYYMMDD') >= '20160101'
                     GROUP BY p.sseguro, TRUNC(p.fecha), DECODE(c.ctipapor, 'PR', 'PR', NULL)) LOOP
            /*Si tenemos Nnumlin, ir a CTASEGURO con el nnumlin y sseguro  y comprobar si
            CTSEGURO.ctipapor=’PR’. En tal caso, indicar un 2 en este campo, 1 en caso contrario.
            */
            --pctipapor := 1;

            /*IF reg.nnumlin IS NOT NULL THEN
               BEGIN
                  SELECT DECODE(UPPER(ctipapor), 'PR', 2, 1)
                    INTO pctipapor
                    FROM ctaseguro
                   WHERE sseguro = reg.sseguro
                     AND nnumlin = reg.nnumlin;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;
            */
            numreg := numreg + 1;
            importepost := NVL(reg.ipricons, 0) + NVL(reg.ircm_neto, 0);
            importeant := 0;

            INSERT INTO trasplaaportaciones
                        (stras, naporta, faporta, cprocedencia,
                         ctipoderecho, importe_post, importe_ant)
                 VALUES (ptrasout, numreg, reg.fecha, DECODE(reg.ctipapor, 'PR', 2, 1),
                         pctipder, importepost, importeant);
         END LOOP;

         UPDATE trasplainout
            SET numaport = numreg,
                anyoaport = (SELECT TO_CHAR(fvalor, 'YYYY')
                               FROM trasplainout
                              WHERE stras = ptrasfin)
          WHERE stras = ptrasout;
      ELSE   --JRH Lo recuperamos del traspaso origen
         INSERT INTO trasplaaportaciones
                     (stras, naporta, faporta, cprocedencia, ctipoderecho, importe_post,
                      importe_ant, nnumlin_ant, nnumlin_post)
            SELECT ptrasout, naporta, faporta, cprocedencia, ctipoderecho, importe_post,
                   importe_ant, nnumlin_ant, nnumlin_post
              FROM trasplaaportaciones
             WHERE stras = ptrasfin;

         SELECT *
           INTO reg_trasp
           FROM trasplainout
          WHERE stras = ptrasfin;

         UPDATE trasplainout
            SET numaport = reg_trasp.numaport,
                anyoaport = reg_trasp.anyoaport
          WHERE stras = ptrasout;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_TRASPASOS.f_llenar_primas', v_npasexec,
                     'ptrasfin: ' || ptrasfin || ' ptrasout: ' || ptrasout,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN SQLCODE;
   END f_llenar_primas;

   /********* ALBERTO ****************
   Informa los campos de TRASPLAINOUT del nuevo traspaso creado "ptrasout" con los campos
   asociados al registro 228 para la póliza del traspaso Origen "ptrasfin"
   **********************************************/
   FUNCTION f_llenar_datos_228(ptrasfin IN NUMBER, ptrasout IN NUMBER)
      RETURN NUMBER IS
      siniestro      NUMBER;
      fecha          DATE;
      numreg         NUMBER := 0;
      v_npasexec     tab_error.ntraza%TYPE := 0;
      psseguro       NUMBER;
      cuantos        NUMBER;
      fpagomenor     DATE;
      fpagomenorant  DATE;
      pisinret       NUMBER;
      xccobroreduc   trasplainout.ccobroreduc%TYPE;
      xanyoreduc     trasplainout.anyoreduc%TYPE;
      xccobroactual  trasplainout.ccobroactual%TYPE;
      xanyoactual    trasplainout.anyoactual%TYPE;
      ximporteacumact trasplainout.importeacumact%TYPE;
      reg_trasp      trasplainout%ROWTYPE;
   BEGIN
      /*1-  Obtener Fecha traspaso: Con la variable xnsinies del siniestro del traspaso origen
      (campo NSINIES de TRASPLAINOUT), acceder a SIN_SINiESTRO por nsinies y obtener FSINIES
      (ver si hay manera más directa, FEFECTO de TRASPLAINOUT por ejemplo ha de ser lo mismo).
      DE MOMENTO MIRAMOS LA MANERA MAS RAPIDA
      */

      /*SELECT NSINIES INTO SINIESTRO
      FROM TRASPLAINOUT WHERE STRAS = ptrasout;

      SELECT FSINIES INTO FECHA FROM SIN_SINIESTRO
      WHERE NSINIES = SINIESTRO;*/

      -- Manera más rapida
      SELECT fvalor
        INTO fecha
        FROM trasplainout
       WHERE stras = ptrasout;

      IF ptrasfin = ptrasout THEN   --JRH Hacemos los cálculos porque estamos iniciando un traspaso de salida y se debe calcular todo
         /*- Buscar siniestros de tipo rescate para el sseguro del traspaso
         origen -> ccausin 4 o 5 en SIN_SINIESTROS,
         para SIN_SINIESTRO.sseguro = al TRASPLAINOUT.sseguro tratado del traspaso origen.

         - Siniestros Finalizados (con estado sin_movsiniestro.cestsin=1
         en sin_movsiniestro.nsinies=sin_siniestro.nsinies  para su último movimiento con nmovsin máximo para el siniestro).

         Para los siniestros encontrados:
         - Ir a la tabla PRIMAS_CONSUMIDAS por cada uno (campo PRIMAS_CONSUMIDAS.NSINIES)
         y ver si alguno tiene alguna aportación con campo FECHA inferior a 01/01/2007.

         Si es así indicar un 1 en este campo (2 en caso contrario).
         */
         xccobroreduc := 2;

         FOR reg IN (SELECT s3.nsinies
                       FROM sin_siniestro s3
                      WHERE s3.sseguro IN(SELECT sseguro
                                            FROM trasplainout
                                           WHERE stras = ptrasfin)
                        AND s3.ccausin IN(4, 5)
                        AND (SELECT s.cestsin
                               FROM sin_movsiniestro s
                              WHERE s.nsinies = s3.nsinies
                                AND s.nmovsin = (SELECT MAX(s2.nmovsin)
                                                   FROM sin_movsiniestro s2
                                                  WHERE s2.nsinies = s.nsinies)) = 1) LOOP
            SELECT COUNT(1)
              INTO cuantos
              FROM primas_consumidas p, ctaseguro c
             WHERE p.nsinies = reg.nsinies
               AND p.sseguro = c.sseguro
               AND p.nnumlin = c.nnumlin
               AND TO_CHAR(NVL(c.fectrasp, p.fecha), 'YYYYMMDD') < '20070101';

            -- BUSCAMOS LA FECHA MENOR
            fpagomenorant := fpagomenor;

            SELECT MIN(p.frescat)   -- MIN(nvl( c.FECTRASP , p.fecha  ))
              INTO fpagomenor
              FROM primas_consumidas p, ctaseguro c
             WHERE p.nsinies = reg.nsinies
               AND p.sseguro = c.sseguro
               AND p.nnumlin = c.nnumlin
               AND TO_CHAR(NVL(c.fectrasp, p.fecha), 'YYYYMMDD') < '20070101';

            IF fpagomenorant < fpagomenor THEN
               fpagomenor := fpagomenorant;
            END IF;

            IF cuantos > 0 THEN
               xccobroreduc := 1;
            END IF;
         --EXIT;
         END LOOP;

         /*Si  el campo anterior vale 2 indicar 0, en caso contrario indicar,
         de los siniestros afectados con aportaciones anteriores al 2007 del campo anterior,
         la fecha de pago menor (campo PRIMAS_CONSUMIDAS.FRESCAT).
         */
         IF xccobroreduc = 2 THEN
            xanyoreduc := 0;
         ELSE
            xanyoreduc := TO_NUMBER(fpagomenor, 'YYYY');
         END IF;

         /* CCOBROACTUAL
         Sumar pagos realizados en siniestros de tipo rescate en la póliza para el año actual.
         Para ello:

         - Buscar siniestros de tipo rescate para el sseguro del traspaso origen -> ccausin 4 o 5
         en SIN_SINIESTROS,  para SIN_SINIESTRO.sseguro = al TRASPLAINOUT.sseguro tratado del
         traspaso origen

         - Siniestros con SIN_SINIESTRO.FSINIES del mismo año que la fecha de traspaso anteriormente
         encontrada.--> Quitar esta condición?

         - Siniestros Finalizados (con estado sin_movsiniestro.cestsin=1
         en sin_movsiniestro.nsinies=sin_siniestro.nsinies  para su último movimiento con nmovsin máximo
         para el siniestro).

         Para los siniestros encontrados anteriormente:
         - Sumar sus pagos (campo ISINRET de la tabla Sin_tramita_pago yendo por el campo NSINIES)
         - que estén activos (sin_tramita_movpago con estado 2 para el último movimiento del pago
         NSINIES.SIDEPAG)
         - y que sin_tramita_movpago.fefecpag sea igual al año indicado.

         Si el valor obtenido es mayor que 0 informar 1 en este campo, 2 en caso contrario.
         */
         xccobroactual := 2;
         ximporteacumact := 0;

         FOR reg IN (SELECT s.nsinies
                       FROM sin_siniestro s
                      WHERE s.sseguro IN(SELECT sseguro
                                           FROM trasplainout
                                          WHERE stras = ptrasfin)
                        AND s.ccausin IN(4, 5)
                        AND TO_CHAR(s.fsinies, 'YYYY') = TO_CHAR(fecha, 'YYYY')
                        AND (SELECT s2.cestsin
                               FROM sin_movsiniestro s2
                              WHERE s2.nsinies = s.nsinies
                                AND s2.nmovsin = (SELECT MAX(s3.nmovsin)
                                                    FROM sin_movsiniestro s3
                                                   WHERE s3.nsinies = s2.nsinies)) = 1) LOOP
            SELECT SUM(isinret)
              INTO pisinret
              FROM sin_tramita_pago, sin_tramita_movpago
             WHERE sin_tramita_pago.sidepag = sin_tramita_movpago.sidepag
               AND sin_tramita_pago.nsinies = reg.nsinies
               AND sin_tramita_movpago.cestpag = 2
               AND sin_tramita_movpago.nmovpag = (SELECT MAX(x.nmovpag)
                                                    FROM sin_tramita_movpago x
                                                   WHERE x.sidepag =
                                                                    sin_tramita_movpago.sidepag)
               AND TO_CHAR(sin_tramita_movpago.fefepag, 'YYYY') = TO_CHAR(fecha, 'YYYY');

            ximporteacumact := ximporteacumact + pisinret;

            IF pisinret > 0 THEN
               xccobroactual := 1;
            END IF;
         --EXIT;
         END LOOP;

         IF xccobroactual = 1 THEN
            xanyoactual := TO_CHAR(fecha, 'YYYY');
         ELSE
            xanyoactual := 0;
         END IF;

         UPDATE trasplainout
            SET ccobroreduc = xccobroreduc,
                anyoreduc = xanyoreduc,
                ccobroactual = xccobroactual,
                anyoactual = xanyoactual,
                importeacumact = ximporteacumact
          WHERE stras = ptrasout;
      ELSE
         --JRH Lo recuperamos del traspaso origen
         SELECT *
           INTO reg_trasp
           FROM trasplainout
          WHERE stras = ptrasfin;

         UPDATE trasplainout
            SET ccobroreduc = reg_trasp.ccobroreduc,
                anyoreduc = reg_trasp.anyoreduc,
                ccobroactual = reg_trasp.ccobroactual,
                anyoactual = reg_trasp.anyoactual,
                importeacumact = reg_trasp.importeacumact
          WHERE stras = ptrasout;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_TRASPASOS.f_llenar_primas', v_npasexec,
                     'ptrasfin: ' || ptrasfin || ' ptrasout: ' || ptrasout,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN SQLCODE;
   END f_llenar_datos_228;
END pac_traspasos;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRASPASOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRASPASOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRASPASOS" TO "PROGRAMADORESCSI";
