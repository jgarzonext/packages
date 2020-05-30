CREATE OR REPLACE FUNCTION F_BUSCACONTRATO (
  psseguro IN NUMBER, fpolefe IN DATE, w_cempres IN NUMBER,
                                                                                     w_cgarant IN NUMBER, w_cramo IN NUMBER, w_cmodali IN NUMBER,
                                                                                     w_ctipseg IN NUMBER, w_ccolect IN NUMBER, w_cactivi IN NUMBER,
                                                                                     pmotiu IN NUMBER, w_scontra OUT NUMBER, w_nversio OUT NUMBER,
                                                                                     w_ipleno OUT NUMBER, w_icapaci OUT NUMBER, w_cdetces OUT NUMBER,
                                                                                     w_cdevento IN NUMBER DEFAULT 0) RETURN NUMBER IS
     /******************************************************************************
      NOMBRE:     F_Buscacontrato
      PROPSITO:     Funcin para buscar contrato de reaseguro
   
      REVISIONES:
      Ver        Fecha        Autor             Descripcin
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX             1. Creacin del package.
      2.0        07/09/2009   FAL             2. Bug 11051: CRE - Pagos sin cesiones. Aadir pmotiu = 2 para llamada a f_busca
      3.0        04/05/2010   AVT             3. 14421: CRE200 - Reaseguro: en los suplementos, no se tiene en cuenta la
                                                 retrocesin de cartera
      4.0        14/05/2010   AVT             4. 14536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                                 en varias agrupaciones de producto
      5.0        23/02/2011   JGR             5. 17672: CEM800 - Contracte Reaseguro 2011 - Aadir nuevo parmetro w_cdetces
      6.0        12/12/2011   JGR             6. 0020023: Reaseguro XL
      7.0        23/04/2013   KBR             7. Reaseguro XL por Eventos
      8.0        13/06/2013   AVT             8. 0026256: LCOL_A004-Reaseguro Autos (se pede asignar un producto a un scontra/nversio)
      9.0        28/06/2013   KBR             9. Reaseguro XL por Eventos
      10.0       14/11/2013   DCT            10.0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
      11.0       03/12/2013   RCL            11. 0029038: LCOL_A002-Revisi? QT Producci?: 10163, 10177, 10178 i 10180
      12.0       04/07/2014   EDA            12. 0028056/177953 Error en la bsqueda de los contratos en suplementos. QT 8672
      13.0       13/10/2014   KBR            13. 0032534: LCOL_A004-0013953: Revisin distribucin de siniestros XL Fase 3B
      14.0       02/09/2016   HRE            14. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
      15.0       20/01/2017   HRE            15. CONF-479: Suplemento aumento de valor
      16.0       21/11/2019   INFORCOL       16. Reaseguro Fase 1 Sprint 1
      17.0       27/11/2019   INFORCOL       17. Reaseguro Fase 1 Sprint 2
      18.0       11/12/2019   ECP            18. IAXIS-5149. Cancelaciones
	  19.0       23/12/2019   INFORCOL       19. Reaseguro Fase 1 Sprint 2 Se habilita la funcionalidad para los tipos de movimiento 9(rehabiltiacion) para poliza con contratos de vigencias anios anteriores
      20.0       11/05/2019   INFORCOL       20. Bug 13854 Recobros busqueda contrato diferente al vigente segun condiciones de la poliza
      21.0       27/05/2020   ECP            21. IAXIS-13888 Gestión Agenda
   ******************************************************************************/
     perr          NUMBER := 0;
     wfefecto      DATE;
     v_retira      NUMBER;
     vntraza       NUMBER := 0;
     w_ilimsub     NUMBER;
     w_sproduc     seguros.sproduc%TYPE; -- 04/07/2014 EDA 0028056/177953
     w_npoliza     seguros.npoliza%TYPE; -- 04/07/2014 EDA 0028056/177953
     w_ncertif     seguros.ncertif%TYPE; -- 13/10/2014 KBR
     w_esrenovable NUMBER; --BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
     n_renova      NUMBER; --CONF-910
     
     --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
     n_err NUMBER :=0;
    --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
     vpar_traza VARCHAR2(80) := 'TRAZA_BUSCA_CONTRATO'; -- LJRF 19/11/19
     /************************************************************************************
      Deixa l'informaci a la taula auxiliar.
      QUADRE DE CERQUES ORDENAT:
      -------------------------
      B1   Ram    Producte    Activitat   Garanta
      B2   Ram    --------    Activitat   Garanta
      B3   Ram    Producte    ---------   Garanta
      B4   Ram    --------    ---------   Garanta
      B5   Ram    Producte    Activitat   --------
      B6   Ram    --------    Activitat   --------
      B7   Ram    Producte    ---------   --------
      B8   Ram    --------    ---------   --------
   
   *************************************************************************************/
     FUNCTION busca(pfefecto IN DATE) RETURN NUMBER IS
     BEGIN
            -- CERCA B1...Producte + Garantia + Activitat
            -- ********
            BEGIN
                 vntraza := 1;
                 -- KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant = w_cgarant
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg = w_ctipseg
                        AND a.ccolect = w_ccolect
                        AND a.cactivi = w_cactivi
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
            
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                  --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            --DBMS_OUTPUT.put_line(' cerca 1 no troba ');
            ---------
            -- Cerca Ram + Mod + Tip + Gar + Act
            BEGIN
                 vntraza := 2;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant = w_cgarant
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg = w_ctipseg
                        AND a.ccolect IS NULL
                        AND a.cactivi = w_cactivi
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                  --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            --DBMS_OUTPUT.put_line(' cerca  1a   no troba ');
            --  Cerca Ram + Mod + Gar + Act
            --
            BEGIN
                 vntraza := 3;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant = w_cgarant
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND a.cactivi = w_cactivi
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
            
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            --DBMS_OUTPUT.put_line('cerca 1b no troba ');
            ---------------
            -- CERCA B2... Ram + Garantia + Activitat
            -- ********
            BEGIN
                 vntraza := 4;
            
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant = w_cgarant
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cactivi = w_cactivi
                        AND a.cmodali IS NULL
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
            
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            ---------------
            -- CERCA B3...
            -- ********
            BEGIN
                 vntraza := 5;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant = w_cgarant
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg = w_ctipseg
                        AND a.ccolect = w_ccolect
                        AND a.cactivi IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            ---------------
            --  Cerca Ram + Mod + Tip + Gar + Act null
            BEGIN
                 vntraza := 6;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant = w_cgarant
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg = w_ctipseg
                        AND a.ccolect IS NULL
                        AND a.cactivi IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            -----------
            ---  Cerca Ram + Mod  + Gar + Act null
            BEGIN
                 vntraza := 7;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant = w_cgarant
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND a.cactivi IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            ---------------
            -- CERCA B4...
            -- ********
            BEGIN
                 vntraza := 8;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant = w_cgarant
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cactivi IS NULL
                        AND a.cmodali IS NULL
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
            
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            ---------------
            -- CERCA B5...
            -- ********
            BEGIN
                 vntraza := 9;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant IS NULL
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg = w_ctipseg
                        AND a.ccolect = w_ccolect
                        AND a.cactivi = w_cactivi
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            -- Cerca Ram + Mod + Tip + Gar null + Act
            BEGIN
                 vntraza := 10;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant IS NULL
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg = w_ctipseg
                        AND a.ccolect IS NULL
                        AND a.cactivi = w_cactivi
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            -- Cerca Ram + Mod + Gar null + Act
            BEGIN
                 vntraza := 11;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant IS NULL
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND a.cactivi = w_cactivi
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            ---------------
            -- CERCA B6...
            -- ********
            BEGIN
                 vntraza := 12;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant IS NULL
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali IS NULL
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND a.cactivi = w_cactivi
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            ---------------
            -- CERCA B7...
            -- ********
            BEGIN
                 vntraza := 12;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant IS NULL
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg = w_ctipseg
                        AND a.ccolect = w_ccolect
                        AND a.cactivi IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            --  Cerca Ram + Mod + Tip + Gar null+ Act null
            BEGIN
                 vntraza := 13;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant IS NULL
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg = w_ctipseg
                        AND a.ccolect IS NULL
                        AND a.cactivi IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            --  Cerca Ram + Mod + Gar null+ Act null
            BEGIN
                 vntraza := 14;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND v.nversio = a.nversio
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND a.cgarant IS NULL
                        AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali = w_cmodali
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND a.cactivi IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        --AND (v.nversio = a.nversio OR NVL(a.nversio, 0) = 0)
                        --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2));
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
     
            ---------------
            -- CERCA B8...
            -- ********
     
            --IAXIS-4773 SE DEBE QUITAR OR  NVERSION=0 DUPLICA EL CONTRATO
            --IAXIS-5149 -- ECP -- 11/12/2019
            BEGIN
                 vntraza := 15;
                 --KBR 23042013 Reaseguro XL por eventos
                 SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, a.ilimsub
                     INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
                     FROM codicontratos c, contratos v, agr_contratos a
                    WHERE c.scontra = v.scontra
                        AND c.scontra = a.scontra
                        AND c.cempres = w_cempres
                        AND a.cgarant IS NULL
                          AND c.finictr <=
								DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) 
						AND (c.ffinctr IS NULL OR
								c.ffinctr >
							DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto))
                            AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                                (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 1 OR c.ctiprea = 2 OR c.ctiprea = 5))) --BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
                        AND a.cramo = w_cramo
                        AND a.cmodali IS NULL
                        AND a.ctipseg IS NULL
                        AND a.ccolect IS NULL
                        AND a.cactivi IS NULL
                        AND v.fconini <=
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto) --CONF-910
                        AND (v.fconfin IS NULL OR
                                v.fconfin >
                                DECODE(NVL(pmotiu, 0), 11, DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto), pfefecto)) --CONF-910
                        AND c.nconrel IS NULL
                             -- 22678 XL por Eventos
                        AND v.nversio = a.nversio
                             --IAXIS4773 INI FEPP 22/08/2019
                             --  OR NVL(a.nversio, 0) = 0)
                             --IAXIS4773 FIN FEPP 22/08/2019  
                             /*AND(v.nversio = a.nversio
               OR NVL(a.nversio, 0) = 0)*/
                        AND ((NVL(c.cdevento, 0) = w_cdevento) OR (NVL(c.cdevento, 0) = 2))
                 
                 ;
                 RETURN(0);
            EXCEPTION
                 WHEN no_data_found THEN
                        NULL; -- seguimos buscando
                 WHEN OTHERS THEN
                 --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                 n_err :=1;
                --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
                        p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres ||
                                                 ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                                 ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi ||
                                                 ' MOTIU=' || pmotiu, SQLERRM);
                        RETURN(104672);
            END;
            --IAXIS-5149 -- ECP -- 11/12/2019
            --INFORCOL INI - 18/11/2019
            IF w_cramo = 802 THEN
                p_traza_proceso(w_cempres, vpar_traza, NULL, NULL, 'F_BUSCACONTRATO', NULL, 1121, 'ENTRO w_cramo = 802');
               BEGIN
                  vntraza := 16;
                  --KBR 23042013 Reaseguro XL por eventos
                  SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces,
                         a.ilimsub
                    INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces,
                         w_ilimsub
                    FROM codicontratos c, contratos v, agr_contratos a
                   WHERE c.scontra = v.scontra
                     AND c.scontra = a.scontra
                     AND c.cempres = w_cempres
                     AND a.cgarant IS NULL
                     AND (c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3) OR
                         (DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0 AND (c.ctiprea = 3)))
                     AND a.cramo = w_cramo
                     AND a.cmodali IS NULL
                     AND a.ctipseg IS NULL
                     AND a.ccolect IS NULL
                     AND a.cactivi IS NULL
                     AND v.fconini <=
                         DECODE(NVL(pmotiu, 0), 11,
                         DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto),
                          pfefecto)
                     AND (v.fconfin IS NULL OR
                          v.fconfin >
                           DECODE(NVL(pmotiu, 0), 11,
                           DECODE(NVL(v.cbasexl, 1), 1, pfefecto, 2, wfefecto),
                           pfefecto))
                     AND c.nconrel IS NULL
                     AND v.nversio = a.nversio
                     AND ((NVL(c.cdevento, 0) = w_cdevento) OR
                          (NVL(c.cdevento, 0) = 2));
                  RETURN(0);
               EXCEPTION
                  WHEN no_data_found THEN
                     NULL;
                  WHEN OTHERS THEN
                     n_err := 1;
                     p_traza_proceso(w_cempres, vpar_traza, NULL, NULL,
                                    'F_BUSCACONTRATO', NULL, 1121,
                                    'ERROR w_cramo = 802 - ' || SQLERRM);
                     p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                'psseguro=' || psseguro || ' POLEFE=' || fpolefe ||
                                ' cempres=' || w_cempres || ' CGARANT=' || w_cgarant ||
                                ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali ||
                                ' CTIPSEG=' || w_ctipseg || ' CCOLECT=' || w_ccolect ||
                                ' CACTIVI=' || w_cactivi || ' MOTIU=' || pmotiu,
                                SQLERRM);
                  RETURN(104672);
               END;
            END IF;
            --INFORCOL FIN - 18/11/2019
            vntraza := 16;
            --INI - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
             IF n_err <> 0
             THEN
                    p_tab_error(f_sysdate, f_user, 'Errores en F_BUSCACONTRATO.busca', vntraza,
                                            'psseguro=' || psseguro || ' pfefecto=' || pfefecto || ' w_cempres=' || w_cempres ||
                                             ' w_cgarant=' || w_cgarant || ' w_cramo=' || w_cramo || ' w_cmodali=' || w_cmodali ||
                                             ' w_ctipseg=' || w_ctipseg || ' w_ccolect=' || w_ccolect || ' w_cactivi=' || w_cactivi ||
                                             ' pmotiu=' || pmotiu || ' wfefecto:' || wfefecto || ' w_cdevento:' || w_cdevento, SQLERRM);
            END IF;
             --FIN - CJAD - 24/SEP2019 - IAXIS5322 - Errores de tab error
            RETURN(104485);
     EXCEPTION
            WHEN OTHERS THEN
                 --         DBMS_OUTPUT.put_line('ERRRRRROR ' || SQLERRM);
                 p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                         'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres || --> BORRAR JGR
                                            ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali || ' CTIPSEG=' ||
                                            w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi || ' MOTIU=' || pmotiu,
                                         SQLERRM);
     END busca;
BEGIN
     w_scontra := NULL;
     w_nversio := NULL;
     vntraza   := 47;
     p_Control_Error ('F_BUSCACONTRATO','F_BUSCACONTRATO','PASO 1, pmotiu:'||pmotiu||' psseguro:'||psseguro||
     ' w_cgarant:'||w_cgarant||' w_cempres:'||w_cempres);
-- Ini 13888 -- 20/05/2020
     IF pmotiu IN (2, 3) THEN
     -- Ini 13888 -- 20/05/2020
            -- 04/07/2014 EDA 0028056/177953
            vntraza := 48;
            perr    := busca(fpolefe);
            --CONF-910 Inicio
     --INFORCOL INI - 23/12/2019 - Se habilita la funcionalidad para los tipos de movimiento 9(rehabiltiacion) para poliza con contratos de vigencias anios anteriores
     ELSIF pmotiu IN (4, 9) THEN
     --INFORCOL FIN - 23/12/2019
         --INFORCOL INI - 27/11/2019
         vntraza := 481;
         BEGIN
             SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, null ilimsub             
               INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
               FROM codicontratos c, contratos v
              WHERE c.scontra = v.scontra
                AND c.cempres = w_cempres
                AND (v.scontra, v.nversio) IN
                (
                  SELECT DISTINCT scontra,nversio 
                    FROM cesionesrea ces, det_cesionesrea dce
                   WHERE ces.sseguro = dce.sseguro 
                     AND ces.scesrea = dce.scesrea
                     AND ces.sseguro = psseguro
                     AND ces.cgenera = 3
                     AND dce.cgarant = NVL(w_cgarant, dce.cgarant)
                );     


                p_Control_Error ('F_BUSCACONTRATO','F_BUSCACONTRATO','PASO 1, pmotiu:'||pmotiu||' psseguro:'||psseguro||
                ' w_cgarant:'||w_cgarant||' w_cempres:'||w_cempres||' w_scontra:'||w_scontra||' w_nversio:'||w_nversio||
                ' w_ipleno:'||w_ipleno||' w_icapaci:'||w_icapaci||' w_cdetces:'||w_cdetces);

           EXCEPTION 
             WHEN OTHERS THEN
               perr    := busca(fpolefe);
           END;          
           --INFORCOL FIN - 27/11/2019

     ELSIF pmotiu = 11 THEN
            --primero buscamos si el contrato de la pliza retira cartera o no
            --RETIRAR CARTERA: al renovar la pliza buscamos el nuevo contrato para la nueva fecha efecto del movimiento de renovacion.
            --NO RETIRAR CARTERA: al renovar la pliza arrastramos el contrato que llevaba asociado al nuevo movimiento de renovacion.
            BEGIN
                 SELECT NVL(MAX(cercartera), 0)
                     INTO v_retira
                     FROM contratos c
                    WHERE (c.scontra, c.nversio) IN
                                (SELECT DISTINCT scontra, nversio
                                     FROM cesionesrea
                                    WHERE sseguro = psseguro
                                        AND (cgarant = w_cgarant OR cgarant IS NULL));
            EXCEPTION
                 WHEN no_data_found THEN
                        v_retira := 0;
                 WHEN OTHERS THEN
                        RETURN 104516;
            END;
     
            --buscamos los datos del seguro
            BEGIN
                 SELECT DISTINCT sproduc, npoliza, ncertif, fefecto
                     INTO w_sproduc, w_npoliza, w_ncertif, wfefecto
                     FROM (SELECT sproduc, npoliza, ncertif, fefecto
                                        FROM estseguros
                                     WHERE sseguro = psseguro
                                    UNION
                                    SELECT sproduc, npoliza, ncertif, fefecto
                                        FROM seguros
                                     WHERE sseguro = psseguro);
            EXCEPTION
                 WHEN OTHERS THEN
                        RETURN 104375;
            END;
     
            --Si retira cartera, tenemos que buscar su ltima fecha efecto de renovacin
            IF v_retira = 1 THEN
            
                 --Miramos cada cuntas renovaciones tenemos que traspasar cartera
                 SELECT DECODE(NVL(pac_parametros.f_parproducto_n(w_sproduc, 'PER_REV_NO_ANUAL_REA'), 1), 0, 1,
                                                NVL(pac_parametros.f_parproducto_n(w_sproduc, 'PER_REV_NO_ANUAL_REA'), 1))
                     INTO n_renova
                     FROM dual;
            
                 --Nos quedamos con la mayor fefecto teniendo en cuenta que solo traspasa cartera cada "n_renova" veces.
                 SELECT MAX(fefecto)
                     INTO wfefecto
                     FROM (SELECT ROWNUM orden, m.fefecto
                                        FROM (SELECT m.fefecto
                                                         FROM movseguro m, seguros s
                                                        WHERE m.sseguro = s.sseguro
                                                            AND s.npoliza = w_npoliza
                                                            AND s.ncertif = w_ncertif
                                                            AND m.fefecto <= fpolefe
                                                            AND nmovimi > 0
                                                            AND cmovseg IN (0, 2)
                                                        ORDER BY fefecto) m)
                    WHERE MOD(orden - 1, n_renova) = 0;
            
                 --Si no retira cartera usaremos su seguros.fefecto encontrado anteriormente
            END IF;
     
            perr := busca(fpolefe);
     
            --CONF-910 Fin
     ELSE
         --INFORCOL INICIO 11-05-2020 Bug 13854 Recobros busqueda contrato diferente al vigente segun condiciones de la poliza
         vntraza := 482;
         BEGIN
            SELECT v.scontra, v.nversio, v.iretenc, v.icapaci, v.cdetces, null ilimsub             
              INTO w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces, w_ilimsub
              FROM codicontratos c, contratos v
             WHERE c.scontra = v.scontra
               AND c.cempres = w_cempres
               AND (v.scontra, v.nversio) IN
               (
                  SELECT DISTINCT scontra,nversio 
                    FROM cesionesrea ces, det_cesionesrea dce
                   WHERE ces.sseguro = dce.sseguro 
                     AND ces.scesrea = dce.scesrea
                     AND ces.sseguro = psseguro
                     AND ces.cgenera = 3
                     AND dce.cgarant = NVL(w_cgarant, dce.cgarant)
                );     
           RETURN(perr);
           EXCEPTION 
             WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'F_BUSCACONTRATO', vntraza, 'psseguro=' || psseguro||'pmotiu -->'||pmotiu, SQLERRM);
         END;        
         --INFORCOL FIN 11-05-2020 Bug 13854 Recobros busqueda contrato diferente al vigente segun condiciones de la poliza

            vntraza := 49;
     
            BEGIN
                 SELECT MAX(NVL(cretira, 0)) -- EDA 28056/177953  04/07/2014 SELECT NVL(cretira, 0)
                     INTO v_retira
                     FROM codicontratos c
                    WHERE c.scontra IN (SELECT DISTINCT scontra
                                                                FROM cesionesrea
                                                             WHERE sseguro = psseguro
                                                                 AND (cgarant = w_cgarant OR cgarant IS NULL));
            EXCEPTION
                 WHEN no_data_found THEN
                        v_retira := 0;
                 WHEN OTHERS THEN
                        perr := 104516;
            END;
     
            vntraza := 50;
     
            IF v_retira = 1 THEN
                 vntraza := 51;
                 perr    := busca(fpolefe);
            ELSE
                 vntraza := 52;
            
                 -- 13/10/2014 KBR Obtenemos el certificado para luego hacer la busqueda por poliza/certificado
                 BEGIN
                        SELECT sproduc, npoliza, ncertif
                            INTO w_sproduc, w_npoliza, w_ncertif
                            FROM estseguros
                         WHERE sseguro = psseguro;
                 EXCEPTION
                        WHEN no_data_found THEN
                             BEGIN
                                    SELECT sproduc, npoliza, ncertif
                                        INTO w_sproduc, w_npoliza, w_ncertif
                                        FROM seguros
                                     WHERE sseguro = psseguro;
                             EXCEPTION
                                    WHEN no_data_found THEN
                                         perr := busca(fpolefe);
                             END;
                        WHEN OTHERS THEN
                             perr := 104375;
                 END;
                 --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
                 SELECT COUNT(0)
                     INTO w_esrenovable
                     FROM parcontratos
                    WHERE sproduc = w_sproduc
                        AND sparcnt = 'REA_MANTIENE_SUPL'
                        AND cvalpar = 1;
                 --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE
            
                 IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'PER_REV_NO_ANUAL_REA'), 0) > 1) OR w_esrenovable = 0 --BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
                    THEN
                        -- 04/07/2014 EDA 0028056/177953
                        perr := busca(fpolefe);
                 ELSE
                        BEGIN
                             -- 13/10/2014 KBR Se aade la condicin por "ncertif" para que la consulta devuelva el valor correcto
                             SELECT MAX(m.fefecto)
                                 INTO wfefecto
                                 FROM movseguro m, seguros s
                                WHERE m.sseguro = s.sseguro
                                    AND s.npoliza = w_npoliza
                                    AND s.ncertif = w_ncertif
                                    AND m.fefecto <= fpolefe -- AVT per migraci!!!! 18/05/2015
                                    AND nmovimi > 0
                                    AND cmovseg IN (0, 2);
                        
                             IF wfefecto IS NULL THEN
                                    vntraza := 53;
                                    perr    := busca(fpolefe);
                             ELSE
                                    vntraza := 54;
                                    perr    := busca(wfefecto);
                             END IF;
                        EXCEPTION
                             WHEN no_data_found THEN
                                    perr := busca(fpolefe);
                             WHEN OTHERS THEN
                                    perr := 104349;
                        END;
                 END IF; -- 04/07/2014 EDA 0028056/177953
            END IF;
     END IF;

     --KBR 24/04/2014: Se aade la condicin del "evento = 0"
     --Limite de suscripcin que aplica para contratos XL por riesgo, evento y cmulo sigue aplicando la capacidad del ctto
     IF psseguro IS NOT NULL AND pmotiu = 11 AND w_cdevento = 0 THEN
            w_icapaci := NVL(w_ilimsub, w_icapaci);
            w_ipleno  := NVL(w_ilimsub, w_icapaci);
     END IF;

     vntraza := 54;
     RETURN(perr);
EXCEPTION
     WHEN OTHERS THEN
            --      DBMS_OUTPUT.put_line('error general : ' || SQLERRM);
            p_tab_error(f_sysdate, f_user, 'f_busca', vntraza,
                                    'psseguro=' || psseguro || ' POLEFE=' || fpolefe || ' cempres=' || w_cempres || --> BORRAR JGR
                                     ' CGARANT=' || w_cgarant || ' CRAMO=' || w_cramo || ' MODALI=' || w_cmodali || ' CTIPSEG=' ||
                                     w_ctipseg || ' CCOLECT=' || w_ccolect || ' CACTIVI=' || w_cactivi || ' MOTIU=' || pmotiu,
                                    SQLERRM);
            RETURN(1);
END f_buscacontrato;
/