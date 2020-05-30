create or replace PACKAGE BODY          "PAC_INFORMES_REA" IS
/******************************************************************************
create or replace
PACKAGE BODY "PAC_INFORMES_REA" IS
/******************************************************************************
   NOMBRE:      PAC_INFORMES_REA


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        31/01/2012   JMF               1. 0021129 LCOL_A002-Listados de reaseguro
   2.0        16/02/2012   JMF               2. 0021129 LCOL_A002-Listados de reaseguro
   4.0        12/07/2012   DCG               4. 0022794 AGM800-Bordero de cesiones
   5.0        03/07/2012   JMF               0022678: LCOL_A002-Qtracker: 0004601: Error en cuenta tecnica de XL
   6.0        03/07/2012   JMF               0022682: LCOL_A002-Qtracker: 0004600: La cesi?n de siniestros XL no es correcta
   7.0        06/08/2012   DCG               7. 0022682: LCOL_A002-Qtracker: 0004600: La cesi?n de siniestros XL no es correcta s
   8.0        28/09/2012   AVT               8. 0022678: LCOL_A002-Qtracker: 0004601: Error en cuenta tecnica de XL
   9.0        28/11/2012   AVT               9. 24881: RSA003 - Parametrizar contrato reaseguro: s'ajusta f_00504_det per pòlissa + certificat
  10.0        11/04/2013   AVT              10. 26605: LCOL896-Soporte a cliente en Colombia (abril/2013) NOTA: 0141994 QT: 6992
  11.0        24/04/2013   AVT              11.0026597: LCOL_A004-Qtracker: 7041: Error en la cuenta técnica de marzo
  12.0        16/05/2013   dlF              12.0026207: AGM998- Cambios en dos listados (facturación y reaseguro)
  13.0        06/06/2013   AVT              13. 22678: LCOL_A002-Qtracker: 0004601: Error en cuenta tecnica de XL
  14.0        30/07/2013   KBR              14. 0022020: LCOL999-Diferencias en las primas de reaseguro (QT: 4555)
  15.0        13/08/2013   dlF              15. 0027912: Problema con el borderó de Reaseguro ( Pólizas Anuladas )
  16.0        13/11/2013   KBR              16. 0028777: Incidencia 28761: POSREA Reaseguro facultativo
  17.0        03/12/2013   KBR              17. 0029038: LCOL_A002-Revisi? QT Producci?: 10177
  18.0        05/03/2014   dlF              18. 0030464: Problemas en el Borderó de de cesiones de reaseguro
  19.0        26/03/2014   KBR              19. 0028991: Incidencia en reporte de reservas XL
  20.0        03/04/2014   DCT              20. 0029038: LCOL_A002-Revisi? QT Producci?: 10163, 10177, 10178 i 10180
  21.0        08/05/2014   DCT              21. 0030326: LCOL_A004-Qtracker: 11612 y 11610 (11903)
  22.0        06/06/2014   DCT              22. 0031734: Qtracker: 0012925: no genera información bordero de siniestros pagados porporcionales
  23.0        13/06/2014   EDA              23. 0029038: Ajustar listado f_00504_det, para simplificarlo. Y no hacer la join con MOVSEGURO.
  24.0        19/06/2014   DCT              24. 0031318: LCOL_A004-Qtracker: 6636: NO SE GENERO CONATBILIZACION A LAS CUENTAS 511110 Y 265410 SIESTRO REASEGUROS
  25.0        19/06/2019   IDR              25. AXIS(4290): Cuenta tecnica del Reaseguro, añadir conceptos(41,45). 
  26.0	      27/06/2019   IDR		        26. AXIS(4478): Bordero de Cesiones, modificación de columnas y Query
  27.0        05/07/2019   IDR	            27	AXIS(4613): Bordero de Siniestros, modificación de columnas y Query
  28.0        25/07/2019   IDR              28. AXIS(4614): Bordero de Reservas Siniestros, modificación de columnas y Query.

******************************************************************************/
   v_txt          VARCHAR2(32000);
   v_txt_2        VARCHAR2(32000);

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Bordero_siniestro.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cmodali     -> modalidad(1: Altas, 3: Anulaciones, 2: Renovaciones)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   FUNCTION f_00504_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cmodali IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00504_CAB';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' m=' || p_cmodali || ' i=' || p_cidioma || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
      -- Bug 0022794 - 12/07/2012 - DCG - Ini
      v_aux_naci     VARCHAR2(500);
      v_aux_sexo     VARCHAR2(500);
   -- Bug 0022794 - 12/07/2012 - DCG - Fi
   BEGIN
      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);

      --v_txt := v_txt || f_axis_literales(9904434, v_idioma);
      IF p_compani IS NULL THEN
         v_ntraza := 1035;
         v_txt := v_txt || CHR(10);
      ELSE
         v_ntraza := 1040;

         SELECT f_axis_literales(9900914, v_idioma) || MAX(c.tcompani)
           INTO v_aux
           FROM companias c
          WHERE c.ccompani = p_compani;

         v_ntraza := 1045;
         v_txt := v_txt || v_aux;
      END IF;

      v_ntraza := 1050;
      v_txt := v_txt || CHR(10) || f_axis_literales(105280, v_idioma) || ' '
               || TO_DATE(LPAD(p_finiefe, 8, '0'), 'ddmmyyyy') || ' - '
               || TO_DATE(LPAD(p_ffinefe, 8, '0'), 'ddmmyyyy');
      v_ntraza := 1055;
      v_txt := v_txt || CHR(10) || CHR(10);
      v_ntraza := 1060;

      v_txt := v_txt
                 -- Nro Identificación
               || f_axis_literales(104813, v_idioma) || v_sep
               ||   -- Contrato
                 f_axis_literales(9000609, v_idioma) || v_sep
               ||   -- Tramo
                 f_axis_literales(9000600, v_idioma) || v_sep
               ||   -- Compañía
                 f_axis_literales(100624, v_idioma) || v_sep
               ||   -- Póliza

               CASE NVL(pac_parametros.f_parlistado_n(p_cempres, 'FIGURAS_504'), 0)
                  WHEN 1 THEN f_axis_literales(9000760, v_idioma) || ' '
                              || f_axis_literales(101027, v_idioma) || v_sep
                              ||   -- NIF/CIF/NIE Tomador
                                f_axis_literales(9000759, v_idioma) || ' '
                              || f_axis_literales(101027, v_idioma) || v_sep
                              ||   -- Nombre y apellido Tomador
                                f_axis_literales(9000760, v_idioma) || ' '
                              || f_axis_literales(101028, v_idioma) || v_sep
                              ||   -- NIF/CIF/NIE Tomador
                                f_axis_literales(9000759, v_idioma) || ' '
                              || f_axis_literales(101028, v_idioma)
                              || v_sep   -- Nombre y apellido Tomador
               END;

      v_ntraza := 1075;

      v_txt := v_txt ||
                f_axis_literales(111625, v_idioma) || v_sep
               ||   -- F.Efecto
                 f_axis_literales(151198, v_idioma) || v_sep
               ||   -- T.movimiento
                 f_axis_literales(151474, v_idioma) || v_sep
               ||   -- F.Movimiento
                 f_axis_literales(104818, v_idioma) || v_sep
               ||   -- % Participación
                 f_axis_literales(103779, v_idioma) || v_sep
               ||   -- % cesión
                 f_axis_literales(104819, v_idioma) || v_sep
               ||   -- Capital cedido
                 f_axis_literales(104820, v_idioma) || v_sep
               ||   -- Prima cedida
                 f_axis_literales(9001923, v_idioma) || v_sep
               ||   -- % Comisión
                 f_axis_literales(9001924, v_idioma) || v_sep
               ||   -- Imp.comisión
                 ' %Ret de Prima' || v_sep
               ||-- %Ret de Prima
                '  Retención de Prima' || v_sep
               ||-- Retencion de Prima
                 f_axis_literales(108645, v_idioma)  ;
                  --  Moneda
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00504_cab;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Bordero_siniestro.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cmodali     -> modalidad(1: Altas, 3: Anulaciones, 2: Renovaciones, 0: Consolidado)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0018819 - 08/07/2011 - JMF
   FUNCTION f_00504_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cmodali IN NUMBER DEFAULT 0,   -- Bugs 29038/177262 EDA 13/06/2014 Simplificar el reporte
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00504_DET';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
           || p_ffinefe || ' m=' || p_cmodali || ' i=' || p_cidioma || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      --v_finiefe      VARCHAR2(100);
      --v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      --v_sep2         VARCHAR2(5) := CHR(39) || ';' || CHR(39);

      -- Bug 0026207 - AGM998- Cambios en dos listados (facturación y reaseguro) - 20-IV-2013 - dlF
      ssep           VARCHAR2(32) := ' || ' || CHR(39) || v_sep || CHR(39) || ' || ';
      ssepret        VARCHAR2(32) := ' || ' || CHR(39) || v_sep || CHR(39) || ' || '
                                     || CHR(13);
      sret           VARCHAR2(2) := CHR(13) || CHR(10);
      -- fin Bug 0026207 - AGM998- Cambios en dos listados (facturación y reaseguro) - 20-IV-2013 - dlF

      -- Bug 0022794 - 12/07/2012 - DCG - Ini
      v_aux_naci     VARCHAR2(500);
      v_aux_sexo     VARCHAR2(500);
   -- Bug 0022794 - 12/07/2012 - DCG - Fi
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Bordero cesiones reaseguro
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
      v_txt := NULL;
      v_ntraza := 1045;
      --KBR 03/12/2013
      v_txt := 'SELECT DISTINCT '
               || 'ct.scontra || ''-'' || ct.nversio || '' '' || ct.tcontra' || ssepret
               || ' c.ctramo  || ''-'' ||  ff_desvalorfijo(105, x.idi, c.ctramo)' || ssepret
               || '       p.tcompani || pac_md_rea.f_compania_cutoff(p.ccompani, SYSDATE)' || ssep || 's.npoliza||'' - ''||s.ncertif' || ssepret
               || CASE NVL(pac_parametros.f_parlistado_n(p_cempres, 'FIGURAS_504'), 0)
                  WHEN 1 THEN '       MAX(pac_isqlfor.f_dni(s.sseguro, 1))' || ssepret
                              || '       MAX(pac_isqlfor.f_persona(s.sseguro, 1))' || ssepret
                              || '       MAX(pac_isqlfor.f_dni(s.sseguro, 2))' || ssepret
                              || '       MAX(pac_isqlfor.f_persona(s.sseguro, 2))' || ssepret
               END;
      v_ntraza := 1075;

      v_txt :=
         v_txt
         || '       s.fefecto' || ssepret || '       DECODE(x.mol, 2, DECODE(s.cforpag, 0, f_axis_literales(9002162, x.idi), f_axis_literales(101875, x.idi)),
                    ff_desvalorfijo(128, x.idi, c.cgenera))'
         || ssepret || ' c.fefecto ' || ssepret
         || '       to_char(NVL(c.pporcen, 0),''FM990D00'')' || ssep
         || 'to_char(NVL(c.pcesion, 0),''FM990D00'')' || ssepret
         ||
         CASE NVL(pac_parametros.f_parlistado_n(p_cempres, 'CAPITAL_CEDIDO'), 0)
            WHEN 0 THEN ' f_round(NVL(c.icapces, 0), 1) * SIGN( SUM(NVL(c.icesion, 0))) '
            ELSE ' f_round(NVL(c.icapces, 0) - ((NVL(c.icapces, 0) / DECODE(NVL(c.icapcet, 0), 0, 1, c.icapcet)) *
                      NVL(NVL((SELECT pm.ipromat
                           FROM provmat pm
                          WHERE pm.sseguro = c.sseguro
                            AND pm.cgarant = c.cgarant
                            AND pm.nriesgo = c.nriesgo
                            AND pm.fcalcul = c.fcierre),
                         (SELECT pm2.ipromat
                           FROM provmat_previo pm2
                          WHERE pm2.sseguro = c.sseguro
                            AND pm2.cgarant = c.cgarant
                            AND pm2.nriesgo = c.nriesgo
                            AND pm2.fcalcul = c.fcierre)),0)), 1) '
         END
         || ssepret || '   NVL(c.icesion, 0)' || ssep
         || ' NVL(c.pcomisi, 0) ' || ssepret
         || ' NVL(c.icomisi, 0) ' || ssepret
         || ' NVL(cs.preserv, 0) ' || ssepret
         || ' NVL(((c.icesion * cs.preserv) /100), 0) ' || ssepret
         || '       em.tmoneda linea' || sret
         || '  FROM seguros s, riesgos r, '
         || '       titulopro t, companias p, contratos ct, codicontratos cc, eco_desmonedas em, '
         || CASE p_cprevio
            WHEN 1 THEN 'reaseguroaux c,  cuadroces cs, '
            ELSE 'reaseguro c,  cuadroces cs, '
         END || sret || '       (SELECT ' || CHR(39) || p_compani || CHR(39) || ' cia,'
         || p_cempres || ' emp,' || CHR(39) || p_finiefe || CHR(39) || ' ini,' || CHR(39)
         || p_ffinefe || CHR(39) || ' fin,' || CHR(39) || p_cmodali || CHR(39) || ' mol,'
         || p_cidioma || ' idi FROM DUAL) x' || sret
         || ' WHERE s.sseguro = c.sseguro AND r.sseguro = c.sseguro' || sret
         || '   AND r.nriesgo = c.nriesgo ' || sret
         || '   AND t.ctipseg = s.ctipseg AND t.cramo = s.cramo' || sret
         || '   AND t.cmodali = s.cmodali AND t.ccolect = s.ccolect' || sret
         || '   AND t.cidioma = x.idi '
         || CASE
            WHEN p_compani IS NOT NULL THEN '   AND c.ccompani = ' || p_compani
            ELSE ' '
         END || sret
         || CASE p_cmodali
         WHEN 0 THEN NULL
         WHEN 3 THEN '   AND c.cgenera = 6 '
         ELSE '   AND c.cgenera <> 6 '
         END
         || sret
         || '   AND s.cempres = x.emp AND pac_anulacion.f_anulada_al_emitir(s.sseguro) = 0'
         || sret
         || ' AND DECODE(x.mol, 0, 0, -- Incluyen todos los movimientos
                       DECODE(c.cgenera, 5, 2,   -- Para la renovación
                       6, 3,   -- En caso de anulación
                       1)) = x.mol   -- En resto de los casos estaran con las Altas'
         || sret || '   AND c.sidepag IS NULL' || sret
         || '   AND TRUNC(c.fcierre) BETWEEN TO_DATE(x.ini, ''ddmmyyyy'') AND TO_DATE(x.fin, ''ddmmyyyy'')'
         || sret || '   AND p.ccompani = c.ccompani AND c.scontra = ct.scontra' || sret
         || '   AND c.nversio = ct.nversio AND cc.SCONTRA= ct.scontra' || sret
         || '   AND em.cmoneda = cc.cmoneda AND em.cidioma = x.idi' || sret
         || '  and c.scontra = cs.scontra  and c.nversio = cs.nversio ' || sret
         || ' GROUP BY x.mol, x.idi, ct.tcontra, c.ctramo,  p.tcompani, pac_md_rea.f_compania_cutoff(p.ccompani, SYSDATE), s.npoliza, s.ncertif,'
         || sret
         || '       r.sperson, c.cgarant, s.fefecto, c.fefecto, c.fvencim,'
         || sret
         || '       s.cforpag, c.pporcen, c.icapces, c.ccompani, c.pcesion,'
         || sret
         || '       c.fcalcul, c.cgenera, r.tnatrie, c.scesrea, ct.scontra, ct.nversio, em.tmoneda,'
         || sret || '       c.icapcet, c.sseguro, c.nriesgo, c.fcierre, c.nmovimi, pcomisi, c.icesion, cs.preserv, c.icomisi' || sret
         || 'HAVING SUM(c.icesion) <> 0';
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00504_det;

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Cuenta técnica
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cinttec     -> interes tecnico
                         - p_ctiprea     -> tipo reaseguro valor.106
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   -- Bug 0022678 - 25/07/2012 - JMF: p_cprevio
   FUNCTION f_00505_cabtecnica(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00505_CABTECNICA';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' i=' || p_cinttec || ' t=' || p_ctiprea || ' i=' || p_cidioma
            || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
   BEGIN

      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);

      IF p_compani IS NULL THEN
         v_ntraza := 1035;
         v_txt := v_txt || CHR(10);
      ELSE
         v_ntraza := 1040;

         SELECT f_axis_literales(9900914, v_idioma) || MAX(p.tapelli)
           INTO v_aux
           FROM companias c, personas p
          WHERE c.ccompani = p_compani
            AND c.sperson = p.sperson;

         v_ntraza := 1045;
         v_txt := v_txt || v_aux;
      END IF;

      v_txt := v_txt || CHR(10);
      v_ntraza := 1050;
      v_txt := v_txt || CHR(10) || f_axis_literales(105280, v_idioma) || ' '
               || TO_DATE(LPAD(p_finiefe, 8, '0'), 'ddmmyyyy') || ' - '
               || TO_DATE(LPAD(p_ffinefe, 8, '0'), 'ddmmyyyy');
      v_ntraza := 1055;
      v_txt := v_txt || CHR(10) || f_axis_literales(9902261, v_idioma) || ': '
               || ff_desvalorfijo(106, v_idioma, p_ctiprea);
      v_txt := v_txt || ' ' || f_axis_literales(9000632, v_idioma) || ': ';

      IF NVL(p_cprevio, 0) = 1 THEN
         v_txt := v_txt || ' ' || f_axis_literales(101778, v_idioma);
      ELSE
         v_txt := v_txt || ' ' || f_axis_literales(101779, v_idioma);
      END IF;

      v_txt := v_txt || CHR(10) || CHR(10);
      v_ntraza := 1056;
      -- CUENTA TÉCNICA
     v_txt := v_txt || f_axis_literales(151744, v_idioma) || CHR(10);
      v_ntraza := 1060;
      v_txt := v_txt || f_axis_literales(104813, v_idioma) || v_sep
               ||   -- Contrato
                 f_axis_literales(100896, v_idioma) || v_sep
             ||   -- Concepto
                 f_axis_literales(101003, v_idioma) || v_sep
               ||   -- Debe
                 f_axis_literales(101004, v_idioma)   -- Haber
                                                   ;
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00505_cabtecnica;

    /******************************************************************************************
      Descripció: Funció que genera texte detall per llistat dinamic Cuenta técnica
      Paràmetres entrada: - p_compani     -> Companyia
                          - p_cempres     -> Empresa
                          - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                          - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                          - p_cinttec     -> interes tecnico
                          - p_ctiprea     -> tipo reaseguro valor.106
                          - p_cidioma     -> Idioma
                          - p_cprevio     -> (0-Real, 1-Previo).
   return:             texte capçelera
    ******************************************************************************************/
    -- Bug 0021129 - 31/01/2012 - JMF
    -- Bug 0022678 - 25/07/2012 - JMF: p_cprevio
    -- IAXIS 4290  - 19/06/2019 - IDR: Añadir valores(41,45), borrar tramo(5), traer todos los contratos. Cursores previos(c2 /  cfacultativoprevio)-definitivos(cfacultativo)
   FUNCTION f_00505_dettecnica(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00505_DETTECNICA';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' i=' || p_cinttec || ' t=' || p_ctiprea || ' i=' || p_cidioma
            || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      d_finiefe      DATE;
      d_ffinefe      DATE;
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
      n_primera      NUMBER(1);
      n_total_debe   NUMBER;
      n_total_haber  NUMBER;

      -- Bug 0022678 - 03/07/2012 - JMF: Añadir valores 15,20,25.
      -- Bug 0022678 - 26/07/2012 - JMF
      -- Cursor per el no previ
      CURSOR c1 IS
         SELECT   tcontra, orden, tatribu, SUM(debe) debe, SUM(haber) haber
             FROM (SELECT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                          DECODE(d.catribu,
                                 1, 1,
                                 5, 2,
                                 3, 3,
                                 6, 4,
                                 4, 5,
                                 7, 6,
                                 9, 7,
                                 2, 8,
                                 15, 9,
                                 20, 10,
                                 22, 11,   -- 22678 AVT 28/09/2012
                                 25, 12,
                                 7, 13,
                                 12, 14,
                                 14, 15,
                                 17, 16,
                                 26, 17,
                                 27, 18,
                                 45, 45,
                                 41, 41) orden,
                          d.tatribu, DECODE(m.cdebhab, 2, 0, m.iimport) debe,
                          DECODE(m.cdebhab, 2, m.iimport, 0) haber   -- 26597 AVT 24/04/2013
                     FROM movctatecnica m, detvalores d, contratos c, codicontratos s
                    WHERE m.scontra = c.scontra
                      AND m.nversio = c.nversio
                      AND m.fmovimi >= d_finiefe
                      AND m.fmovimi <= d_ffinefe
                      AND m.ccompani = p_compani
                      AND m.cconcep = d.catribu
                      AND cvalor = 124
                      AND cidioma = v_idioma
                      AND(
                          -- Proporcional
                          (ctiprea IN(1, 2)
                           AND d.catribu IN(1, 2, 3, 4, 5, 6, 7, 9, 12, 14, 17, /*25,*/ 26, 27))   -- BUG 25373 - FAL - 18/10/2013 - Se excluye concepto 25(reservas siniestros). Se incluye en f_00505_detreservassini
                          OR
                            -- contracte XL
                          (  ctiprea in (3, 5)
                             AND d.catribu IN(12, 5, 17, 20, 22 /*, 25*/,45 ,41)))   -- 22678: AVT 06/06/2013 ES CANVIA EL CONCEPTE 15 PEL 5  -- BUG 25373 - FAL - 18/10/2013 - Se excluye concepto 25(reservas siniestros). Se incluye en f_00505_detreservassini
                      AND m.scontra = s.scontra
                      AND m.cempres = s.cempres
                      AND s.cempres = p_cempres
                      AND ctiprea = p_ctiprea
                      AND m.ctramo <> NVL(pac_parametros.f_parlistado_n(p_cempres,
                                                                        'SINFACUL_505'),
                                          -1))
            WHERE debe <> 0
               OR haber <> 0
         GROUP BY tcontra, orden, tatribu
        ORDER BY 1, 2;

      -- Bug 0022678 - 26/07/2012 - JMF
      -- Cursor per el previ
      CURSOR c2 IS
         SELECT   tcontra, orden, tatribu, SUM(debe) debe, SUM(haber) haber
             FROM (SELECT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                          DECODE(d.catribu,
                                 1, 1,
                                 5, 2,
                                 3, 3,
                                 6, 4,
                                 4, 5,
                                 7, 6,
                                 9, 7,
                                 2, 8,
                                 15, 9,
                                 20, 10,
                                 22, 11,   -- 22678 AVT 28/09/2012
                                 25, 12,
                                 7, 13,
                                 12, 14,
                                 14, 15,
                                 17, 16,
                                 26, 17,
                                 27, 18,
                                 45, 45,
                                 41, 41) orden,
                          d.tatribu, DECODE(m.cdebhab, 2, 0, m.iimport) debe,   -- 26597 AVT 24/04/2013
                          DECODE(m.cdebhab, 2, m.iimport, 0) haber
                     FROM movctaaux m, detvalores d, contratos c, codicontratos s
                    WHERE m.scontra = c.scontra
                      AND m.nversio = c.nversio
                      AND m.fmovimi >= d_finiefe
                      AND m.fmovimi <= d_ffinefe
                      AND m.ccompani = p_compani
                      AND m.cconcep = d.catribu
                      AND cvalor = 124
                      AND cidioma = v_idioma
                      AND(
                          -- Proporcional
                         (ctiprea IN(1, 2)
                      AND d.catribu IN(1, 2, 3, 4, 5, 6, 7, 9, 12, 14, 17, /*25,*/ 26, 27))   -- BUG 25373 - FAL - 18/10/2013 - Se excluye concepto 25(reservas siniestros). Se incluye en f_00505_detreservassini
                       OR
                            -- contracte XL
                          (  ctiprea IN (3,5)
                             AND d.catribu IN(12, 5, 17, 20, 22, /*, 25*/45, 41)))   -- 22678: AVT 06/06/2013 ES CANVIA EL CONCEPTE 15 PEL 5   -- BUG 25373 - FAL - 18/10/2013 - Se excluye concepto 25(reservas siniestros). Se incluye en f_00505_detreservassini
                      AND m.scontra = s.scontra
                      AND m.cempres = s.cempres
                      AND s.cempres = p_cempres
                      AND ctiprea = p_ctiprea
                      AND m.ctramo <> NVL(pac_parametros.f_parlistado_n(p_cempres,
                                                                        'SINFACUL_505'),
                                          -1))
            WHERE debe <> 0
               OR haber <> 0
         GROUP BY tcontra, orden, tatribu
         ORDER BY 1, 2;

      -- Bug 32084 - 21/07/2014 - dlF - Reaseguro - Cuenta Técnica - Desglose del facultativo
      CURSOR cfacultativo IS
         SELECT   tcontra, orden, tatribu, SUM(debe) debe, SUM(haber) haber
             FROM (SELECT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                          DECODE(d.catribu,
                                 1, 1,
                                 5, 2,
                                 3, 3,
                                 6, 4,
                                 4, 5,
                                 7, 6,
                                 9, 7,
                                 2, 8,
                                 15, 9,
                                 20, 10,
                                 22, 11,   -- 22678 AVT 28/09/2012
                                 25, 12,
                                 7, 13,
                                 12, 14,
                                 14, 15,
                                 17, 16,
                                 26, 17,
                                 27, 18,
                                 45, 45,
                                 41, 41) orden,
                          d.tatribu, DECODE(m.cdebhab, 2, 0, m.iimport) debe,
                          DECODE(m.cdebhab, 2, m.iimport, 0) haber
                     FROM movctatecnica m, detvalores d, contratos c
                    WHERE  m.scontra = c.scontra
                       AND m.nversio = c.nversio
                      AND  m.fmovimi >= d_finiefe
                      AND m.fmovimi <= d_ffinefe
                      AND m.ccompani = p_compani
                      AND m.cconcep = d.catribu
                      AND cvalor = 124
                      AND cidioma = v_idioma
                      -- FAC. Proporcional
                      AND d.catribu IN(1, 2, 3, 4, 5, 6, 7, 9, 12, 14, 17, 26, 27, 41, 45))
                      --AND m.ctramo = 5)
            WHERE debe <> 0
               OR haber <> 0
         GROUP BY tcontra, orden, tatribu
         ORDER BY 1, 2;

      CURSOR cfacultativoprevio IS
         SELECT   tcontra, orden, tatribu, SUM(debe) debe, SUM(haber) haber
             FROM (SELECT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                          DECODE(d.catribu,
                                 1, 1,
                                 2, 2,
                                 3, 3,
                                 4, 4,
                                 5, 5,
                                 6, 6,
                                 7, 7,
                                 9, 8,
                                 15, 9,
                                 20, 10,
                                 22, 11,   -- 22678 AVT 28/09/2012
                                 25, 12,
                                 7, 13,
                                 12, 14,
                                 14, 15,
                                 17, 16,
                                 26, 17,
                                 27, 18,
                                 45, 45,
                                 41, 41) orden,
                          d.tatribu, DECODE(m.cdebhab, 2, 0, m.iimport) debe,
                          DECODE(m.cdebhab, 2, m.iimport, 0) haber
                     FROM movctaaux m, detvalores d, contratos c
                    WHERE m.scontra = c.scontra
                     AND m.nversio = c.nversio
                      AND m.fmovimi >= d_finiefe
                      AND m.fmovimi <= d_ffinefe
                      AND m.ccompani = p_compani
                      AND m.cconcep = d.catribu
                      AND cvalor = 124
                      AND cidioma = v_idioma
                      -- FAC. Proporcional
                      AND d.catribu IN(1, 2, 3, 4, 5, 6, 7, 9, 12, 14, 17, 26, 27,45,41))
                     -- AND m.ctramo = 5)
            WHERE debe <> 0
               OR haber <> 0
         GROUP BY tcontra, orden, tatribu
         ORDER BY 1, 2;

      FUNCTION f_returnquery(
         porden NUMBER,
         pcontrato VARCHAR2,
         pseparador VARCHAR2,
         patributo VARCHAR2,
         pdebe NUMBER,
         phaber NUMBER,
         psetunion INTEGER,
         ptotaldebe IN OUT NUMBER,
         ptotalhaber IN OUT NUMBER)
         RETURN VARCHAR2 IS
      BEGIN

         ptotaldebe := ptotaldebe + pdebe;
         ptotalhaber := ptotalhaber + phaber;
         RETURN CASE psetunion
                   WHEN 1 THEN ' union'
                   ELSE ''
                END || ' select ' || porden || ', ' || CHR(39) || pcontrato || CHR(39) || '||'
                || CHR(39) || pseparador || CHR(39) || '||' || CHR(39) || patributo || CHR(39)
                || '||' || CHR(39) || pseparador || CHR(39) || '||' || CHR(39) || pdebe
                || CHR(39) || '||' || CHR(39) || pseparador || CHR(39) || '||' || CHR(39)
                || phaber || CHR(39) || '||' || CHR(39) || pseparador || CHR(39)
                || ' linea from dual';
      END;
   -- fin Bug 32084 - 21/07/2014 - dlF - Reaseguro - Cuenta Técnica - Desglose del facultativo
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Cuenta técnica reaseguro
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
      v_txt := NULL;

      IF p_compani IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1047;
      d_finiefe := TO_DATE(LPAD(TO_CHAR(p_finiefe), 8, '0'), 'ddmmyyyy');
      v_ntraza := 1053;
      d_ffinefe := TO_DATE(LPAD(TO_CHAR(p_ffinefe), 8, '0'), 'ddmmyyyy');
      v_txt := NULL;
      n_primera := 0;
      n_total_debe := 0;
      n_total_haber := 0;

      -- Bug 32084 - 21/07/2014 - dlF - Reaseguro - Cuenta Técnica - Desglose del facultativo
      IF p_ctiprea IS NOT NULL
         AND p_ctiprea = 5 THEN
         IF NVL(p_cprevio, 0) = 1 THEN
            FOR f1 IN cfacultativoprevio LOOP
               v_txt := v_txt
                        || f_returnquery(f1.orden, f1.tcontra, v_sep, f1.tatribu, f1.debe,
                                         f1.haber, n_primera, n_total_debe, n_total_haber);
               n_primera := 1;
            END LOOP;
         ELSE
            FOR f2 IN cfacultativo LOOP
               v_txt := v_txt
                        || f_returnquery(f2.orden, f2.tcontra, v_sep, f2.tatribu, f2.debe,
                                         f2.haber, n_primera, n_total_debe, n_total_haber);
               n_primera := 1;
            END LOOP;
         END IF;
      ELSE
         -- fin Bug 32084 - 21/07/2014 - dlF - Reaseguro - Cuenta Técnica - Desglose del facultativo
         IF NVL(p_cprevio, 0) = 0 THEN
            FOR f1 IN c1 LOOP
               v_txt := v_txt
                        || f_returnquery(f1.orden, f1.tcontra, v_sep, f1.tatribu, f1.debe,
                                         f1.haber, n_primera, n_total_debe, n_total_haber);
               n_primera := 1;
            END LOOP;
         ELSE
            FOR f2 IN c2 LOOP
               v_txt := v_txt
                        || f_returnquery(f2.orden, f2.tcontra, v_sep, f2.tatribu, f2.debe,
                                         f2.haber, n_primera, n_total_debe, n_total_haber);
               n_primera := 1;
            END LOOP;
         END IF;
      END IF;

      IF n_primera = 0 THEN
         v_txt := 'select 0, null linea from dual ';
      END IF;

      v_txt := v_txt || ' union select 98, ' || 'null' || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) || 'Total' || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) || n_total_debe || CHR(39) || '||' || CHR(39) || v_sep
               || CHR(39) || '||' || CHR(39) || n_total_haber || CHR(39) || '||' || CHR(39)
               || v_sep || CHR(39) || ' linea from dual';
      v_txt := v_txt || ' union select 99, ' || 'null' || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) || 'SALDO' || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) ||(n_total_haber - n_total_debe) || CHR(39) || '||'
               || CHR(39) || v_sep || CHR(39) || '||' || CHR(39) || '0' || CHR(39) || '||'
               || CHR(39) || v_sep || CHR(39) || ' linea from dual';
      v_txt := 'select linea from (' || v_txt || ')';
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00505_dettecnica;

    /******************************************************************************************
      Descripció: Funció que genera texte capçelera per llistat dinamic Cuenta técnica
      Paràmetres entrada: - p_compani     -> Companyia
                          - p_cempres     -> Empresa
                          - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                          - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                          - p_cinttec     -> interes tecnico
                          - p_ctiprea     -> tipo reaseguro valor.106
                          - p_cidioma     -> Idioma
                          - p_cprevio     -> (0-Real, 1-Previo).
   return:             texte capçelera
    ******************************************************************************************/
    -- Bug 0021129 - 31/01/2012 - JMF
    -- Bug 0022678 - 25/07/2012 - JMF: p_cprevio
   FUNCTION f_00505_cabdeposito(
     p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00505_CABDEPOSITO';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' i=' || p_cinttec || ' t=' || p_ctiprea || ' i=' || p_cidioma
            || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
   --v_aux          VARCHAR2(500);


   BEGIN

      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);
      v_ntraza := 1056;
      v_txt := 'SELECT ' || 'chr(10)||' || CHR(39) || f_axis_literales(9900923, v_idioma)
               || CHR(39) || '||chr(10)||' || CHR(39) || f_axis_literales(104813, v_idioma)
               || v_sep   -- Contrato
                       || f_axis_literales(100896, v_idioma) || v_sep   -- Concepto
               || f_axis_literales(101003, v_idioma) || v_sep   -- Debe
               || f_axis_literales(101004, v_idioma)   -- Haber
                                                    || CHR(39) || ' linea from dual';
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00505_cabdeposito;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Cuenta técnica
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cinttec     -> interes tecnico
                         - p_ctiprea     -> tipo reaseguro valor.106
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   -- Bug 0022678 - 25/07/2012 - JMF: p_cprevio
   FUNCTION f_00505_detdeposito(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00505_DETDEPOSITO';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' i=' || p_cinttec || ' t=' || p_ctiprea || ' i=' || p_cidioma
            || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      d_finiefe      DATE;
      d_ffinefe      DATE;
      v_sep          VARCHAR2(1) := ';';
     v_idioma       NUMBER;
      n_primera      NUMBER(1);
      n_total_debe   NUMBER;
      n_total_haber  NUMBER;


      -- Bug 0022678 - 26/07/2012 - JMF
      -- Cursor per no previ
      CURSOR c1 IS
         SELECT   tcontra, orden, tatribu, SUM(debe) debe, SUM(haber) haber
             FROM (SELECT DISTINCT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                                   DECODE(d.catribu, 54, 1, 52, 2, 51, 3) orden, d.tatribu,
                                   0 debe, 0 haber
                              FROM movctatecnica m, detvalores d, contratos c, codicontratos s
                             WHERE m.scontra = c.scontra
                               AND m.nversio = c.nversio
                               AND m.fmovimi >= d_finiefe
                               AND m.fmovimi <= d_ffinefe
                               AND m.ccompani = p_compani
                               AND cvalor = 124
                               AND cidioma = v_idioma
                               AND d.catribu IN(54, 52, 51)
                               AND m.scontra = s.scontra
                               AND s.cempres = p_cempres
                               AND ctiprea = p_ctiprea
                   UNION
                   SELECT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                          DECODE(d.catribu, 54, 1, 52, 2, 51, 3) orden, d.tatribu,

                          --DECODE(d.catribu, 54, 0, m.iimport) debe,
                          --DECODE(d.catribu, 54, m.iimport, 0) haber
                          DECODE(m.cdebhab, 2, 0, m.iimport) debe,   -- 26597 AVT 10/05/2013
                          DECODE(m.cdebhab, 2, m.iimport, 0) haber
                     FROM movctatecnica m, detvalores d, contratos c, codicontratos s
                    WHERE m.scontra = c.scontra
                      AND m.nversio = c.nversio
                      AND m.fmovimi >= d_finiefe
                      AND m.fmovimi <= d_ffinefe
                      AND m.ccompani = p_compani
                      AND m.cconcep = d.catribu
                      AND cvalor = 124
                      AND cidioma = v_idioma
                      AND d.catribu IN(54, 52, 51)
                      AND m.scontra = s.scontra
                      AND s.cempres = p_cempres
                      AND ctiprea = p_ctiprea)
            -- BUG 25373 - FAL - 18/10/2013
         WHERE    debe <> 0
               OR haber <> 0
         -- FI BUG 25373 - FAL - 18/10/2013
         GROUP BY tcontra, orden, tatribu
         ORDER BY 1, 2;

      -- Bug 0022678 - 26/07/2012 - JMF
      -- Cursor per no previ
      CURSOR c2 IS
         SELECT   tcontra, orden, tatribu, SUM(debe) debe, SUM(haber) haber
             FROM (SELECT DISTINCT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                                   DECODE(d.catribu, 54, 1, 52, 2, 51, 3) orden, d.tatribu,
                                   0 debe, 0 haber
                              FROM movctaaux m, detvalores d, contratos c, codicontratos s
                             WHERE m.scontra = c.scontra
                               AND m.nversio = c.nversio
                               AND m.fmovimi >= d_finiefe
                               AND m.fmovimi <= d_ffinefe
                               AND m.ccompani = p_compani
                               AND cvalor = 124
                               AND cidioma = v_idioma
                               AND d.catribu IN(54, 52, 51)
                               AND m.scontra = s.scontra
                               AND s.cempres = p_cempres
                               AND ctiprea = p_ctiprea
                   UNION
                   SELECT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                          DECODE(d.catribu, 54, 1, 52, 2, 51, 3) orden, d.tatribu,

                          --DECODE(d.catribu, 54, 0, m.iimport) debe,
                          --DECODE(d.catribu, 54, m.iimport, 0) haber
                          DECODE(m.cdebhab, 2, 0, m.iimport) debe,   -- 26597 AVT 10/05/2013
                          DECODE(m.cdebhab, 2, m.iimport, 0) haber
                     FROM movctaaux m, detvalores d, contratos c, codicontratos s
                    WHERE m.scontra = c.scontra
                      AND m.nversio = c.nversio
                      AND m.fmovimi >= d_finiefe
                      AND m.fmovimi <= d_ffinefe
                      AND m.ccompani = p_compani
                      AND m.cconcep = d.catribu
                      AND cvalor = 124
                      AND cidioma = v_idioma
                      AND d.catribu IN(54, 52, 51)
                      AND m.scontra = s.scontra
                      AND s.cempres = p_cempres
                      AND ctiprea = p_ctiprea)
            -- BUG 25373 - FAL - 18/10/2013
         WHERE    debe <> 0
               OR haber <> 0
         -- FI BUG 25373 - FAL - 18/10/2013
         GROUP BY tcontra, orden, tatribu
         ORDER BY 1, 2;

   BEGIN

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Cuenta técnica reaseguro
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
      v_txt := NULL;

      IF p_compani IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
     ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1045;
      d_finiefe := TO_DATE(LPAD(TO_CHAR(p_finiefe), 8, '0'), 'ddmmyyyy');
      v_ntraza := 1047;
      d_ffinefe := TO_DATE(LPAD(TO_CHAR(p_ffinefe), 8, '0'), 'ddmmyyyy');
      v_txt := NULL;
      n_primera := 0;
      n_total_debe := 0;
      n_total_haber := 0;

      IF NVL(p_cprevio, 0) = 0 THEN
         FOR f1 IN c1 LOOP
            IF n_primera = 1 THEN
               v_txt := v_txt || ' union';
            END IF;

            n_primera := 1;
            v_txt := v_txt || ' select ' || f1.orden || ', ' || CHR(39) || f1.tcontra
                     || CHR(39) || '||' || CHR(39) || v_sep || CHR(39) || '||' || CHR(39)
                     || f1.tatribu || CHR(39) || '||' || CHR(39) || v_sep || CHR(39) || '||'
                     || CHR(39) || f1.debe || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
                     || '||' || CHR(39) || f1.haber || CHR(39) || '||' || CHR(39) || v_sep
                     || CHR(39) || ' linea from dual';
            n_total_debe := n_total_debe + f1.debe;
            n_total_haber := n_total_haber + f1.haber;
         END LOOP;
      ELSE
         FOR f2 IN c2 LOOP
            IF n_primera = 1 THEN
               v_txt := v_txt || ' union';
            END IF;

            n_primera := 1;
            v_txt := v_txt || ' select ' || f2.orden || ', ' || CHR(39) || f2.tcontra
                     || CHR(39) || '||' || CHR(39) || v_sep || CHR(39) || '||' || CHR(39)
                     || f2.tatribu || CHR(39) || '||' || CHR(39) || v_sep || CHR(39) || '||'
                     || CHR(39) || f2.debe || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
                     || '||' || CHR(39) || f2.haber || CHR(39) || '||' || CHR(39) || v_sep
                     || CHR(39) || ' linea from dual';
            n_total_debe := n_total_debe + f2.debe;
            n_total_haber := n_total_haber + f2.haber;
         END LOOP;
      END IF;

      IF n_primera = 0 THEN
         v_txt := 'select 0, null linea from dual ';
      END IF;

      v_txt := v_txt || ' union select 98, ' || 'null' || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) || 'Total' || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) || n_total_debe || CHR(39) || '||' || CHR(39) || v_sep
               || CHR(39) || '||' || CHR(39) || n_total_haber || CHR(39) || '||' || CHR(39)
               || v_sep || CHR(39) || ' linea from dual';
      v_txt := 'select linea from (' || v_txt || ')';
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00505_detdeposito;

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Bordero_siniestro.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_ctipsin     -> Siempre pagado --> anulado Tipus siniestro(1=Reservado, 2=Pagado)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
  FUNCTION f_00506_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_ctipsin IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00506_CAB';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' t=' || p_ctipsin || ' i=' || p_cidioma || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
   BEGIN
      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1025;
      v_txt := CHR(10);

      IF p_compani IS NULL THEN
         v_ntraza := 1035;
         v_txt := v_txt || CHR(10);
      ELSE
         v_ntraza := 1040;

         SELECT f_axis_literales(9900914, v_idioma) || MAX(C.tcompani)
           INTO v_aux
           FROM companias c
          WHERE c.ccompani = p_compani;

         v_ntraza := 1045;
         v_txt := v_txt || v_aux;
      END IF;

      v_ntraza := 1050;
      v_txt := v_txt || CHR(10) || f_axis_literales(105280, v_idioma) || ' '
               || TO_DATE(LPAD(p_finiefe, 8, '0'), 'ddmmyyyy') || ' - '
               || TO_DATE(LPAD(p_ffinefe, 8, '0'), 'ddmmyyyy');
      v_ntraza := 1055;
      v_txt := v_txt || CHR(10) || CHR(10);
      v_ntraza := 1030;
      v_txt := v_txt || f_axis_literales(104813, v_idioma) || v_sep
               ||   -- Contrato
                 f_axis_literales(9000609, v_idioma) || v_sep
               ||   -- Tramo
                 f_axis_literales(9000600, v_idioma) || v_sep
               ||   -- Compañía
                 f_axis_literales(9001875, v_idioma) || v_sep
               ||   -- Póliza
                f_axis_literales(800279, v_idioma) || v_sep
               ||  --N° de sniestro
                 f_axis_literales(9900927, v_idioma) || v_sep
               ||   -- F.comunicación
                 f_axis_literales(801256, v_idioma) || v_sep
               ||   -- F.Ocurrencia
                 f_axis_literales(101040, v_idioma) || v_sep
               ||   -- Causa
                 f_axis_literales(801260, v_idioma) || v_sep
               ||   -- F.Apertura
                 f_axis_literales(101573, v_idioma) || v_sep
               ||   -- Fecha pago
                    'Ref_pago_sin' || v_sep
               || --Referencia de Pago
                   f_axis_literales(104818, v_idioma) || v_sep
               ||  -- % Participación
                  ' % Cesion ' || v_sep
               ||
                 ' Monto_Siniestro_Total '|| v_sep
               ||   -- Monto del Siniestro
                   f_axis_literales(9900928, v_idioma) || v_sep
               ||   -- Prima total participación
                   ' Valor_Sini_Cedido' || v_sep
               ||   --Valor del siniestro cedido
                  'Valor_Recobro ' || v_sep
               ||    --Valor del Recobro
                  ' Valor_recobro_cedido' || v_sep
               ||
                  f_axis_literales(108645, v_idioma) || v_sep
               || --  Moneda
                   f_axis_literales(112259, v_idioma)
                   --estado del siniestro
                                                   ;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00506_cab;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Bordero_siniestro.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_ctipsin     -> Siempre pagado --> anulado Tipus siniestro(1=Reservado, 2=Pagado)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0018819 - 08/07/2011 - JMF
  FUNCTION f_00506_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_ctipsin IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00506_DET';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' t=' || p_ctipsin || ' i=' || p_cidioma || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Bordero siniestros
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1045;
      v_finiefe := LPAD(p_finiefe, 8, '0');
      v_ntraza := 1047;
      v_finiefe := 'to_date(' || CHR(39) || v_finiefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 1050;
      v_ffinefe := LPAD(p_ffinefe, 8, '0');
      v_ntraza := 1053;
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';

      IF NVL(pac_parametros.f_parempresa_n(p_cempres, 'MODULO_SINI'), 0) = 0 THEN
         -- Modul sinistres anterior
         v_ntraza := 1055;

         IF p_cprevio = 1 THEN
            v_txt_2 := '||(((((select v.isinret from sin_tramita_pago v WHERE v.sidepag = ( select  g.sidepag from sin_tramita_movpago g where g.cestpag = 2
                                                                        and g.sidepag = v.sidepag) and v.nsinies = c.nsinies and v.ctippag <> 7) 
                                                                        * c.pporcen) /100) * c.pcesion) / 100)||';
         ELSE
            v_txt_2 := '||null||'; 
         END IF;

         v_txt :=
            ' SELECT ct.scontra || ''-'' || ct.nversio || '' '' || ct.tcontra||' || CHR(39)
            || v_sep || CHR(39) || '||ff_desvalorfijo(105, ' || v_idioma || ', c.ctramo) ||'
            || CHR(39) || v_sep || CHR(39) || '|| p.tcompani || pac_md_rea.f_compania_cutoff(p.ccompani, SYSDATE) ||' || CHR(39) || v_sep || CHR(39)
            || '|| s.npoliza ||'' - ''||s.ncertif ||' || CHR(39) || v_sep || CHR(39)
            || '|| si.nsinies ||' || CHR(39) || v_sep || CHR(39)
            || '||si.fnotifi||' || CHR(39) || v_sep || CHR(39) 
            || '||si.fsinies||'|| CHR(39) || v_sep || CHR(39)
            || '||(SELECT tmotsin FROM desmotsini d WHERE d.cmotsin = si.cmotsin AND d.cramo = s.cramo AND d.ccausin = si.ccausin AND d.cidioma = '|| v_idioma || ')||' || CHR(39) || v_sep || CHR(39) 
            || '||si.fentrad||' || CHR(39) || v_sep || CHR(39) 
            || '||c.fcierre||' || CHR(39) || v_sep || CHR(39)
            || '|| c.sidepag ||' || CHR(39) || v_sep || CHR(39)
	        || '|| ABS(c.pcesion) || ' || CHR(39) || v_sep || CHR(39)
            || '|| ABS(c.pporcen) || '  || CHR(39) || v_sep || CHR(39) 
            || '||(select p.isinret from sin_tramita_pago p WHERE p.sidepag = ( select  l.sidepag from sin_tramita_movpago l where l.cestpag = 2
                                                and l.sidepag = p.sidepag) and p.nsinies = c.nsinies and p.ctippag <> 7)|| ' || CHR(39) || v_sep || CHR(39)
            || '|| (((select n.isinret from sin_tramita_pago n WHERE n.sidepag = ( select  r.sidepag from sin_tramita_movpago r where r.cestpag = 2
                                                                        and r.sidepag = n.sidepag) and n.nsinies = c.nsinies and n.ctippag <> 7) 
                                                                        * c.pporcen) /100) || ' || CHR(39)|| v_sep || CHR(39) 
            || v_txt_2 || CHR(39) || v_sep || CHR(39) 
            || '||(select t.isinret from sin_tramita_pago t  where t.nsinies = c.nsinies and t.CTIPPAG = 7) || ' || CHR(39) || v_sep || CHR(39) 
            || '||(((((select t.isinret from sin_tramita_pago t  where t.nsinies = c.nsinies and t.CTIPPAG = 7 ) * c.pporcen) /100)
                    * c.pcesion ) / 100) || ' || CHR(39) || v_sep || CHR(39)
            || '|| em.tmoneda || ' || CHR(39) || v_sep || CHR(39)
            || '|| (select ff_desvalorfijo(930,' || v_idioma || ', u.cesttra) from sin_tramita_movimiento u where u.nmovtra = (select max(o.nmovtra) from sin_tramita_movimiento o
                     where o.nsinies = u.nsinies) and nsinies =c.nsinies) ||' || CHR(39) || v_sep || CHR(39)
            || ' linea'
            || ' FROM seguros s, riesgos r, siniestros si, pagosini pa, CONTRATOS CT, companias p, codicontratos cc, eco_desmonedas em, ';

         IF p_cprevio = 1 THEN
            v_txt := v_txt || ' reaseguroaux c,';
         ELSE
            v_txt := v_txt || ' reaseguro c,';
         END IF;

         v_txt := v_txt || ' WHERE s.sseguro = c.sseguro' || '   AND r.sseguro = c.sseguro'
                  || '   AND r.nriesgo = c.nriesgo' || '   AND s.cempres = ' || p_cempres
                  || '   AND pac_anulacion.f_anulada_al_emitir(s.sseguro)=0'
                  || '   AND s.sseguro = si.sseguro' || '   AND c.nsinies = si.nsinies'
                  || '   AND si.nsinies = pa.nsinies' || '   AND CT.SCONTRA = C.SCONTRA'
                  || '   AND CT.NVERSIO = C.NVERSIO' || '   AND p.CCOMPANI = C.CCOMPANI'
                  || '   and cc.SCONTRA= ct.scontra' || '   and em.cmoneda = cc.cmoneda'
                  || '   and (c.sidepag = (select max( s.sidepag) from reaseguro s where s.nsinies = c.nsinies ) 
                            OR c.sidepag = (select max( r.sidepag) from reaseguroaux r where r.nsinies = c.nsinies ))'
                  || '   and em.cidioma = ' || v_idioma;

         IF p_compani IS NOT NULL THEN
            v_txt := v_txt || ' AND c.ccompani = ' || p_compani;
         END IF;

         v_txt :=
            v_txt || '   AND pa.cestpag = 2'   --||p_ctipsin
            || '   AND TRUNC(c.fcierre) BETWEEN ' || v_finiefe || ' AND ' || v_ffinefe
            || '   GROUP BY ct.tcontra, c.ctramo,  p.tcompani, pac_md_rea.f_compania_cutoff(p.ccompani, SYSDATE), s.npoliza, s.ncertif, si.nsinies, r.sperson, si.fnotifi, si.fsinies, si.cmotsin, si.fentrad, c.pcesion, c.icapces, c.ccompani, s.cramo, si.ccausin, c.fcierre, ct.scontra, ct.nversio, em.tmoneda, c.sidepag, c.nsinies, c.icesiot, c.sseguro, c.pporcen';
      ELSE
         -- Modul sinistres nou
         IF p_cprevio = 1 THEN
            v_txt_2 := '||(((((select f.isinret from sin_tramita_pago f WHERE f.sidepag = ( select  x.sidepag from sin_tramita_movpago x where x.cestpag = 2
                                                                        and x.sidepag = f.sidepag) and f.nsinies = c.nsinies and f.ctippag <> 7) 
                                                                        * c.pporcen) /100) * c.pcesion) / 100)||';
         ELSE
            v_txt_2 := '||null||';
         END IF;

         v_txt :=
            ' SELECT ct.scontra || ''-'' || ct.nversio || '' '' || ct.tcontra||' || CHR(39)
            || v_sep || CHR(39) || '||ff_desvalorfijo(105, ' || v_idioma || ', c.ctramo) ||'
            || CHR(39) || v_sep || CHR(39) || '|| p.tcompani || pac_md_rea.f_compania_cutoff(p.ccompani, SYSDATE) ||' || CHR(39) || v_sep || CHR(39)
            || '|| s.npoliza ||'' - ''||s.ncertif ||' || CHR(39) || v_sep || CHR(39)
            || '|| si.nsinies ||' || CHR(39) || v_sep || CHR(39)
            || '||si.fnotifi||' || CHR(39) || v_sep || CHR(39) 
            || '||si.fsinies||' || CHR(39) || v_sep || CHR(39)       
            || '||(select sdc.TCAUSIN from sin_descausa sdc where sdc.CCAUSIN=si.ccausin and sdc.CIDIOMA='|| v_idioma || ')||' || CHR(39) || v_sep || CHR(39)
            || '||si.falta||' || CHR(39)|| v_sep || CHR(39) 
            || '||pa.fordpag||' || CHR(39) || v_sep || CHR(39)
            || '|| c.sidepag ||' || CHR(39) || v_sep || CHR(39)
	        || '|| ABS(c.pcesion) || ' || CHR(39) || v_sep || CHR(39) 
            || '|| ABS(c.pporcen) || '  || CHR(39) || v_sep || CHR(39) 
            || '||(select p.isinret from sin_tramita_pago p WHERE p.sidepag = ( select  l.sidepag from sin_tramita_movpago l where l.cestpag = 2
                                                and l.sidepag = p.sidepag) and p.nsinies = c.nsinies and p.ctippag <> 7)|| ' || CHR(39) || v_sep || CHR(39)
             || '||(((select n.isinret from sin_tramita_pago n WHERE n.sidepag = ( select  r.sidepag from sin_tramita_movpago r where r.cestpag = 2
                                                                        and r.sidepag = n.sidepag) and n.nsinies = c.nsinies and n.ctippag <> 7) 
                                                                        * c.pporcen) /100)|| ' || CHR(39)|| v_sep || CHR(39) 
            || v_txt_2 || CHR(39) || v_sep || CHR(39) 
            || '||(select t.isinret from sin_tramita_pago t  where t.nsinies = c.nsinies and t.CTIPPAG = 7) || ' || CHR(39) || v_sep || CHR(39) 
            || '||(((((select t.isinret from sin_tramita_pago t  where t.nsinies = c.nsinies and t.CTIPPAG = 7 ) * c.pporcen) /100)
                    * c.pcesion ) / 100) || ' || CHR(39) || v_sep || CHR(39)
            || '|| em.tmoneda || ' || CHR(39) || v_sep || CHR(39)
            || '||(select ff_desvalorfijo(930,' || v_idioma || ', u.cesttra) from sin_tramita_movimiento u where u.nmovtra = (select max(o.nmovtra) from sin_tramita_movimiento o
                     where o.nsinies = u.nsinies) and nsinies =c.nsinies)||' || CHR(39) || v_sep || CHR(39)
            || ' linea'
            || ' FROM seguros s, riesgos r, sin_siniestro si, CONTRATOS CT, companias p, codicontratos cc, eco_desmonedas em,';

         IF p_cprevio = 1 THEN
            v_txt := v_txt || ' reaseguroaux c,';
         ELSE
            v_txt := v_txt || ' reaseguro c,';
         END IF;

         v_txt :=
            v_txt
            || '      (select max(nsinies) nsinies, max(fordpag) fordpag, (sum(isinret) - sum(iretenc)) impor, max(cestpag) cestpag, mp.sidepag'
            || '        from sin_tramita_pago sp, sin_tramita_movpago mp'
            || '       where mp.sidepag = sp.sidepag'
            || '        and mp.nmovpag = (select max(mp2.nmovpag) from sin_tramita_movpago mp2 '
            || '                             where mp2.sidepag = mp.sidepag'
            || '                               and mp2.cestpag = NVL(pac_parametros.f_parempresa_n('
            || p_cempres || ',''EDO_PAGO_PROCESA_REA''),2)'
            || '                               and trunc(mp2.fcontab) BETWEEN ' || v_finiefe
            || ' AND ' || v_ffinefe || '                          )'
            || '        group by mp.sidepag' || '        ) pa'
            || ' WHERE s.sseguro = c.sseguro' || ' and c.sidepag = pa.sidepag'
            || ' AND r.sseguro = c.sseguro' || ' AND r.nriesgo = c.nriesgo'
            || ' AND s.cempres = ' || p_cempres
            || ' AND pac_anulacion.f_anulada_al_emitir(s.sseguro)=0'
            || ' AND s.sseguro = si.sseguro' || ' AND c.nsinies = si.nsinies'
            || ' AND si.nsinies = pa.nsinies' || ' AND CT.SCONTRA = C.SCONTRA'
            || ' AND CT.NVERSIO = C.NVERSIO' || ' AND p.CCOMPANI = C.CCOMPANI'
            || ' and cc.SCONTRA= ct.scontra' || ' and em.cmoneda = cc.cmoneda'
            || '  and (c.sidepag = (select max( s.sidepag) from reaseguro s where s.nsinies = c.nsinies ) 
                            OR c.sidepag = (select max( r.sidepag) from reaseguroaux r where r.nsinies = c.nsinies ))'
            || ' and em.cidioma = ' || v_idioma;

         IF p_compani IS NOT NULL THEN
            v_txt := v_txt || ' AND c.ccompani = ' || p_compani;
         END IF;

         v_txt :=
            v_txt
            || ' GROUP BY ct.tcontra, c.ctramo, p.tcompani, pac_md_rea.f_compania_cutoff(p.ccompani, SYSDATE), s.npoliza, s.ncertif, si.nsinies, r.sperson, si.fnotifi, si.fsinies, si.cmotsin, si.falta,c.pcesion, c.icapces, c.ccompani,s.cramo, si.ccausin, pa.fordpag, ct.scontra, ct.nversio, em.tmoneda, c.sidepag, c.nsinies, c.icesiot, c.sseguro, c.pporcen';
      END IF;

      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00506_det;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00507_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00507_CAB';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' f=' || p_ffinefe || ' i='
            || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
   BEGIN
      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

        SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);

      IF p_compani IS NULL THEN
         v_ntraza := 1035;
         v_txt := v_txt || CHR(10);
      ELSE
         v_ntraza := 1040;

         SELECT f_axis_literales(9900914, v_idioma) || MAX(c.tcompani)
           INTO v_aux
           FROM companias c
          WHERE c.ccompani = p_compani;

         v_ntraza := 1045;
         v_txt := v_txt || v_aux;
      END IF;

      v_ntraza := 1050;
      v_txt := v_txt || CHR(10) || f_axis_literales(105280, v_idioma) || ' '
               || TO_DATE(LPAD(p_ffinefe, 8, '0'), 'ddmmyyyy');
      v_ntraza := 1055;
      v_txt := v_txt || CHR(10) || CHR(10);
      v_ntraza := 1060;
      v_txt := v_txt || f_axis_literales(104813, v_idioma) || v_sep
               ||   -- Contrato
                  f_axis_literales(9000609, v_idioma) || v_sep
               ||   -- Tramo
                  f_axis_literales(9000600, v_idioma) || v_sep
               ||   -- Compañía
                  f_axis_literales(800279, v_idioma) || v_sep
               ||   -- Núm. siniestro                                                   
                  f_axis_literales(801256, v_idioma) || v_sep
               ||   -- F.Ocurrencia
                  f_axis_literales(801260, v_idioma) || v_sep
               ||   -- F.Apertura
                  f_axis_literales(100624, v_idioma) || v_sep
               ||   -- Póliza
                  f_axis_literales(110994, v_idioma) || v_sep
               ||   -- Garantía
                   ' Total_Reserva ' || v_sep
               ||   
                    ' % Cesion ' || v_sep
               ||
                   ' Valor_Reserva_Ced' || v_sep
               ||  
                  f_axis_literales(104818, v_idioma) || v_sep
               ||  -- % Participación
                   'Reserva_Participacion'  || v_sep
               ||
                  f_axis_literales(108645, v_idioma);  
                   --  Moneda;                                          
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00507_cab;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00507_det(
     p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00507_DET';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' f=' || p_ffinefe || ' i='
            || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_ffinefe      VARCHAR2(100);
      --v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(5) := CHR(39) || ';' || CHR(39);
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Bordero cesiones reaseguro
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1050;
      v_ffinefe := LPAD(p_ffinefe, 8, '0');
      v_ntraza := 1053;
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 1055;
      v_txt :=
         ' SELECT l.scontra || ''-'' || l.nversio || '' '' || s.tcontra||' || v_sep2
         || ' ||ff_desvalorfijo(105,' || v_idioma || ',l.ctramo) ||' || v_sep2
         || ' ||o.tcompani||pac_md_rea.f_compania_cutoff(o.ccompani, SYSDATE)||' || v_sep2 
         || ' ||l.nsinies||' || v_sep2 
         || ' ||n.fsinies||' || v_sep2 
         || ' || (select p.falta from sin_siniestro p where p.nsinies = l.nsinies)||' || v_sep2
         || ' ||l.npoliza||' || v_sep2
         || ' ||l.cgarant||' || v_sep2
         || ' ||   (select (s.ireserva) from sin_tramita_reserva s where s.NMOVRES = (select max(i.nmovres) from sin_tramita_reserva i
                    where i.nsinies = s.nsinies) and s.nsinies = l.nsinies  and s.ireserva <> 0 ) || ' || v_sep2           
         || ' ||  l.pporcen ||'|| v_sep2          
         || ' || (((select (n.ireserva) from sin_tramita_reserva n where n.NMOVRES = (select max(o.nmovres) from sin_tramita_reserva o
                    where o.nsinies = n.nsinies) and n.nsinies = l.nsinies) * l.pporcen) / 100)||' || v_sep2           
         || ' || abs(c.pcesion) ||' || v_sep2
         || ' || (((((select (f.ireserva) from sin_tramita_reserva f where f.NMOVRES = (select max(e.nmovres) from sin_tramita_reserva e
                    where e.nsinies = f.nsinies  ) and f.nsinies = l.nsinies  ) * l.pporcen) / 100) * c.pcesion ) /100) ||' || v_sep2
         || '|| em.tmoneda || ' || v_sep2 
         || ' linea'
         || ' FROM reaseguro l, cuadroces c, contratos s, companias o, codicontratos cc, eco_desmonedas em,  sin_siniestro n'
         || ' WHERE l.cempres = ' || p_cempres || ' AND fcierre = ' || v_ffinefe;

      IF p_compani IS NOT NULL THEN
         v_txt := v_txt || ' AND l.ccompani = ' || p_compani;
      END IF;

      v_txt := v_txt || '      AND l.scontra = s.scontra' || '      AND l.nversio = s.nversio'
               || '      AND l.scontra = c.scontra' || '      AND l.nversio = c.nversio'
               || '      AND l.ctramo = c.ctramo'   || '      AND l.ccompani = c.ccompani' 
               || '      AND l.ccompani = o.ccompani'  || '      and cc.scontra = s.scontra' 
               || '      and em.cmoneda = cc.cmoneda'  || '   and l.nsinies = n.nsinies' 
               || '      and (l.sidepag = (select max( s.sidepag) from reaseguro s where s.nsinies = l.nsinies ))'
               || '      and (l.sidepag = (select max(n.sidepag) from sin_tramita_reserva n where n.nsinies = l.nsinies and n.ireserva <> 0))'
               || '      and em.cidioma = ' || v_idioma
               || ' ORDER BY l.npoliza, l.nsinies, l.scontra, l.nversio, l.ctramo, l.cgarant';
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00507_det;


   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             texte capçelera
   ******************************************************************************************/

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Liquida_xl_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
    return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00508_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00508_CAB';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' f=' || p_ffinefe || ' i='
            || p_cidioma || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
   BEGIN
      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);

      IF p_compani IS NULL THEN
         v_ntraza := 1035;
         v_txt := v_txt || CHR(10);
      ELSE
         v_ntraza := 1040;

         SELECT f_axis_literales(9900914, v_idioma) || MAX(p.tapelli)
           INTO v_aux
           FROM companias c, personas p
          WHERE c.ccompani = p_compani
            AND c.sperson = p.sperson;

         v_ntraza := 1045;
         v_txt := v_txt || v_aux;
      END IF;

      v_ntraza := 1050;
      v_txt := v_txt || CHR(10) || f_axis_literales(105280, v_idioma) || ' '
               || TO_DATE(LPAD(p_ffinefe, 8, '0'), 'ddmmyyyy');
      v_ntraza := 1055;
      v_txt := v_txt || CHR(10) || CHR(10);
      v_ntraza := 1060;
      v_txt := v_txt || f_axis_literales(104813, v_idioma) || v_sep
               ||   -- Contrato
                 f_axis_literales(9000609, v_idioma) || v_sep
               ||   -- Tramo
                 f_axis_literales(9000600, v_idioma) || v_sep
               ||   -- Compañía
                 f_axis_literales(800279, v_idioma) || v_sep
               ||   -- Núm. siniestro
                 f_axis_literales(100587, v_idioma) || v_sep
               ||   -- Estado
                 f_axis_literales(100883, v_idioma) || v_sep
               ||   -- Fecha efecto
                 f_axis_literales(100563, v_idioma) || v_sep
               ||   -- Importe
                 f_axis_literales(9902656, v_idioma) || v_sep
               ||   -- Imp. Moneda
                 f_axis_literales(9900897, v_idioma) || v_sep
               ||   -- Fecha cambio
                 f_axis_literales(108645, v_idioma) || v_sep   --  Moneda
                                                            ;
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00508_cab;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Liquida_xl_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00508_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00508_DET';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' f=' || p_ffinefe || ' i='
            || p_cidioma || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_ffinefe      VARCHAR2(100);
      --v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(5) := CHR(39) || ';' || CHR(39);
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Bordero cesiones reaseguro
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1050;
      v_ffinefe := LPAD(p_ffinefe, 8, '0');
      v_ntraza := 1053;
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 1055;
      v_txt :=
         ' SELECT p.scontra || ''-'' || p.nversio || '' '' || s.tcontra||' || v_sep2
         || ' ||ff_desvalorfijo(105,' || v_idioma || ',p.ctramo) ||' || v_sep2
         || ' ||o.tcompani||pac_md_rea.f_compania_cutoff(o.ccompani, SYSDATE)||' || v_sep2 || ' ||nsinies||' || v_sep2 || ' ||ff_desvalorfijo(1061,'
         || v_idioma || ',p.cestliq) ||' || v_sep2 || ' ||p.fefecto||' || v_sep2
         || ' ||f_round(iliqrea)||' || v_sep2 || ' ||iliqrea_moncon||' || v_sep2
         || ' ||fcambio||' || v_sep2 || ' ||em.tmoneda||' || v_sep2 || ' linea'
         || ' FROM codicontratos c, contratos s, companias o, codicontratos cc, eco_desmonedas em';

      IF p_cprevio = 1 THEN
         v_txt := v_txt || ', pagosreaxl_aux p';
      ELSE
         v_txt := v_txt || ', pagosreaxl p';
      END IF;

      v_txt := v_txt || ' WHERE c.cempres = ' || p_cempres || ' AND fcierre = ' || v_ffinefe;

      IF p_compani IS NOT NULL THEN
         v_txt := v_txt || ' AND p.ccompani = ' || p_compani;
      END IF;

      v_txt := v_txt || '      AND p.scontra = c.scontra' || '      AND p.scontra = s.scontra'
               || '      AND p.nversio = s.nversio' || '      AND p.ccompani = o.ccompani'
               || '      and cc.SCONTRA= s.scontra' || '      and em.cmoneda = cc.cmoneda'
               || '      and em.cidioma = ' || v_idioma;
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00508_det;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea_XL.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0022682 - 03/07/2012 - JMF
   FUNCTION f_00533_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00533_CAB';
      v_tparam       VARCHAR2(1000)
        := ' c=' || p_compani || ' e=' || p_cempres || ' f=' || p_ffinefe || ' i='
            || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
   BEGIN
      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);

      IF p_compani IS NULL THEN
         v_ntraza := 1035;
         v_txt := v_txt || CHR(10);
      ELSE
         v_ntraza := 1040;

         SELECT f_axis_literales(9900914, v_idioma) || MAX(p.tapelli)
           INTO v_aux
           FROM companias c, personas p
          WHERE c.ccompani = p_compani
            AND c.sperson = p.sperson;

         v_ntraza := 1045;
         v_txt := v_txt || v_aux;
      END IF;

      v_ntraza := 1050;
      v_txt := v_txt || CHR(10) || f_axis_literales(105280, v_idioma) || ' '
               || TO_DATE(LPAD(p_ffinefe, 8, '0'), 'ddmmyyyy');
      v_ntraza := 1055;
      v_txt := v_txt || CHR(10) || CHR(10);
      v_ntraza := 1060;
      v_txt := v_txt || f_axis_literales(104813, v_idioma) || v_sep
               ||   -- Contrato
                 f_axis_literales(9000609, v_idioma) || v_sep
               ||   -- Tramo
                 f_axis_literales(9000600, v_idioma) || v_sep
               ||   -- Compañía
                 f_axis_literales(800279, v_idioma) || v_sep
               ||   -- Núm. siniestro
                 f_axis_literales(110521, v_idioma) || v_sep
               ||   -- F. siniestro
                 f_axis_literales(9001156, v_idioma) || v_sep
               ||   -- Importe reservas
                 f_axis_literales(9903686, v_idioma) || v_sep
               ||   -- Importe reserva reaseguro
                 -- Bug 0022682 - 12/07/2012 - DCG - Ini (Canviar els literals corresponents a la cabçalera)
                 f_axis_literales(9904096, v_idioma) || v_sep
               -- Bug 0022682 - 12/07/2012 - DCG - Fi
               ||   -- importe reserva neta
                 f_axis_literales(9001509, v_idioma) || v_sep
               ||   -- Importe reservas Gastos
                 f_axis_literales(9903918, v_idioma) || v_sep
               ||   -- Importe reservas moneda
                 f_axis_literales(9903919, v_idioma) || v_sep
               ||   -- Importe reserva reaseguro moneda
                 f_axis_literales(9903920, v_idioma) || v_sep
               ||   -- importe reserva neta moneda
                 f_axis_literales(9903921, v_idioma) || v_sep
              ||   -- Importe reservas Gastos moneda
                 f_axis_literales(108645, v_idioma) || v_sep   --  Moneda
                                                            ;
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00533_cab;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea_XL.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0022682 - 03/07/2012 - JMF
   FUNCTION f_00533_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00533_DET';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' f=' || p_ffinefe || ' i='
           || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_ffinefe      VARCHAR2(100);
      --v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(5) := CHR(39) || ';' || CHR(39);
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Bordero cesiones reaseguro XL
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1050;
      v_ffinefe := LPAD(p_ffinefe, 8, '0');
      v_ntraza := 1053;
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 1055;
      v_txt :=
         ' SELECT l.scontra || ''-'' || l.nversio || '' '' || s.tcontra||' || v_sep2
        || ' ||ff_desvalorfijo(105,' || v_idioma || ',l.ctramo) ||' || v_sep2
         || ' ||o.tcompani||pac_md_rea.f_compania_cutoff(o.ccompani, SYSDATE)||' || v_sep2 || ' ||nsinies||' || v_sep2 || ' ||FSINIES||' || v_sep2
         || ' ||f_round(l.IRESERV)||' || v_sep2 || ' ||f_round(l.IRESREA)||' || v_sep2
         || ' ||f_round(l.IRESNET)||' || v_sep2 || ' ||f_round(l.IRESGAS)||' || v_sep2
         || ' ||l.IRESERV_MONCON||' || v_sep2 || ' ||l.IRESREA_MONCON||' || v_sep2
         || ' ||l.IRESNET_MONCON||' || v_sep2 || ' ||l.IRESGAS_MONCON||' || v_sep2
         || ' || em.tmoneda || ' || v_sep2 || ' linea'
         || ' FROM cuadroces c, contratos s, companias o, codicontratos cc, eco_desmonedas em';

      IF p_cprevio = 1 THEN
         v_txt := v_txt || ', LIQUIDAREAXL_AUX l';
      ELSE
         v_txt := v_txt || ', LIQUIDAREAXL l';
      END IF;

      v_txt := v_txt || ' WHERE cc.cempres = ' || p_cempres || ' AND fcierre = ' || v_ffinefe;

      IF p_compani IS NOT NULL THEN
         v_txt := v_txt || ' AND l.ccompani = ' || p_compani;
      END IF;

      v_txt := v_txt || '      AND l.scontra = s.scontra' || '      AND l.nversio = s.nversio'
               || '      AND l.scontra = c.scontra' || '      AND l.nversio = c.nversio'
               || '      AND l.ccompani = c.ccompani' || '  AND l.ctramo = c.ctramo'
               || '      AND l.ccompani = o.ccompani' || '      and cc.scontra = s.scontra'
               || '      and em.cmoneda = cc.cmoneda' || '      and em.cidioma = '
               || v_idioma   -- 22678 AVT 06/06/2013 || '      and l.IRESERV <> 0'
               || ' ORDER BY nsinies, l.scontra, l.nversio, l.ctramo';
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00533_det;

   /******************************************************************************************
     Descripció: Funció que genera texte capçalera per llistat primes devengades reaseguro Prima_dev_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             text capçalera
   ******************************************************************************************/
   -- Bug 26718-XVM-09/05/2013
   FUNCTION f_00580_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00580_CAB';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' i=' || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
   BEGIN
      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);

      IF p_compani IS NULL THEN
         v_ntraza := 1035;
         v_txt := v_txt || CHR(10);
      ELSE
         v_ntraza := 1040;

         SELECT f_axis_literales(9900914, v_idioma) || MAX(p.tapelli)
           INTO v_aux
           FROM companias c, personas p
          WHERE c.ccompani = p_compani
            AND c.sperson = p.sperson;

         v_ntraza := 1045;
         v_txt := v_txt || v_aux;
      END IF;

      v_ntraza := 1050;
      v_txt := v_txt || CHR(10) || f_axis_literales(105280, v_idioma) || ' '
               || TO_DATE(LPAD(p_finiefe, 8, '0'), 'ddmmyyyy') || ' - '
               || TO_DATE(LPAD(p_ffinefe, 8, '0'), 'ddmmyyyy');
      v_ntraza := 1055;
      v_txt := v_txt || CHR(10) || CHR(10);
      v_ntraza := 1060;
      v_txt := v_txt || f_axis_literales(104813, v_idioma) || v_sep
               ||   -- Contrato
                 f_axis_literales(9000609, v_idioma) || v_sep
               ||   -- Tramo
                 f_axis_literales(9000600, v_idioma) || v_sep
               ||   -- Compañía
                 f_axis_literales(100624, v_idioma) || v_sep;
                     -- Póliza
      -- Bug 0022794 - 12/07/2012 - DCG - Ini
      v_ntraza := 1075;
      v_txt := v_txt || f_axis_literales(100829, v_idioma) || v_sep
               ||   -- Producto
                 f_axis_literales(111625, v_idioma) || v_sep
               ||   --  F.Efecto
                 f_axis_literales(102526, v_idioma) || v_sep
               ||   -- F.vencim
                 f_axis_literales(9001870, v_idioma) || v_sep
                                                             --  Cesión
      ;
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00580_cab;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat primes devengades reaseguro Prima_dev_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                        - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             text detall
   ******************************************************************************************/
   -- Bug 26718-XVM-09/05/2013
   FUNCTION f_00580_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00580_DET';
      v_tparam       VARCHAR2(1000)
        := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' i=' || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      --v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(5) := CHR(39) || ';' || CHR(39);
      v_cidioma      NUMBER := NVL(p_cidioma, 1);
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Bordero cesiones reaseguro
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
     v_txt := NULL;
      v_ntraza := 1045;
      v_finiefe := LPAD(p_finiefe, 8, '0');
      v_ntraza := 1047;
      v_finiefe := 'to_date(' || CHR(39) || v_finiefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 1050;
      v_ffinefe := LPAD(p_ffinefe, 8, '0');
      v_ntraza := 1053;
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 1055;
      v_txt := 'SELECT cu.scontra || ''-'' || cu.nversio || '' '' || ct.tcontra||' || v_sep2
               || '||ff_desvalorfijo(105, x.idi, cu.ctramo) ||' || v_sep2
               || '|| p.tcompani||pac_md_rea.f_compania_cutoff(p.ccompani, SYSDATE) ||' || v_sep2 || '|| s.npoliza||'' - ''||s.ncertif ||'
               || v_sep2;
      -- Bug 0022794 - 12/07/2012 - DCG - Ini
      v_ntraza := 1075;
      v_txt :=
         v_txt || '|| t.ttitulo || ''-'' || s.sproduc ||' || v_sep2
         || '|| NVL(TO_CHAR(c.fefecto, ''dd/mm/rrrr''), '' '') ||' || v_sep2
         || '|| NVL(TO_CHAR(c.fvencim, ''dd/mm/rrrr''), '' '') ||' || v_sep2
         || '|| SUM(ROUND(c.icesion * decode(tr.ctramo,1,(100 -tr.plocal),cu.pcesion)/ 100, 2)) ||'
         || v_sep2 || ' linea'
         || ' FROM cesionesrea c, cuadroces cu, contratos ct, companias p, seguros s, titulopro t,';
      v_txt := v_txt || ' (SELECT ' || CHR(39) || p_compani || CHR(39) || ' cia,' || p_cempres
               || ' emp,' || CHR(39) || p_finiefe || CHR(39) || ' ini,' || CHR(39)
               || p_ffinefe || CHR(39) || ' fin,' || v_cidioma
               || ' idi FROM DUAL) x, tramos tr'
               || ' WHERE c.nversio = cu.nversio AND c.scontra = cu.scontra'
               || ' AND c.ctramo = cu.ctramo   AND c.nversio = cu.nversio'
               || ' AND ct.nversio = c.nversio AND cu.ctramo = c.ctramo'
               || ' AND cu.ccompani = p.ccompani AND s.sseguro = c.sseguro'
               || ' AND t.cramo = s.cramo AND t.cmodali = s.cmodali'
               --Bug 0022794 - 26/07/2012 - DCG || '    AND DECODE(m.cmovseg, 3, 0, m.nmovimi) = c.nmovimi';
               || '  AND t.ccolect = s.ccolect AND t.ctipseg = s.ctipseg';
      v_txt := v_txt || ' AND t.cidioma = x.idi AND c.scontra = ct.scontra'
               || ' AND c.nversio = ct.nversio ' || ' AND c.fcontab BETWEEN ' || v_finiefe
               || ' and ' || v_ffinefe;

      IF p_compani IS NOT NULL THEN
         v_txt := v_txt || ' AND cu.ccompani = ' || p_compani;
      END IF;

      v_txt :=
         v_txt || ' AND tr.ctramo = cu.ctramo and tr.SCONTRA = cu.scontra'
         || ' AND tr.nversio = cu.nversio'
         || ' GROUP BY cu.scontra, cu.nversio, ct.tcontra, x.idi, cu.ctramo, p.tcompani, pac_md_rea.f_compania_cutoff(p.ccompani, SYSDATE), s.npoliza,'
         || ' s.ncertif, t.ttitulo, s.sproduc, c.fefecto, c.fvencim'
         || ' HAVING SUM(icesion) <> 0';
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00580_det;

   -- BUG 25373 - FAL - 18/10/2013
   FUNCTION f_00505_cabreservassini(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00505_CABRESERVASSINI';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' i=' || p_cinttec || ' t=' || p_ctiprea || ' i=' || p_cidioma
            || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
   --v_aux          VARCHAR2(500);
   BEGIN
      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);
      v_ntraza := 1056;
      v_txt := 'SELECT ' || 'chr(10)||' || CHR(39) || f_axis_literales(9906149, v_idioma)
               || CHR(39) || '||chr(10)||' || CHR(39) || f_axis_literales(104813, v_idioma)
               || v_sep   -- Contrato
                       || f_axis_literales(100896, v_idioma) || v_sep   -- Concepto
               || f_axis_literales(101003, v_idioma) || v_sep   -- Debe
               || f_axis_literales(101004, v_idioma)   -- Haber
                                                    || CHR(39) || ' linea from dual';
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00505_cabreservassini;

   FUNCTION f_00505_detreservassini(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00505_DETRESERVASSINI';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' i=' || p_finiefe || ' f='
            || p_ffinefe || ' i=' || p_cinttec || ' t=' || p_ctiprea || ' i=' || p_cidioma
            || ' p=' || p_cprevio;
      v_ntraza       NUMBER := 0;
      d_finiefe      DATE;
      d_ffinefe      DATE;
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
      n_primera      NUMBER(1);
      n_total_debe   NUMBER;
      n_total_haber  NUMBER;

      -- Bug 0022678 - 03/07/2012 - JMF: Añadir valores 15,20,25.
      -- Bug 0022678 - 26/07/2012 - JMF
      -- IAXIS - 4290 - 19/06/2019 - IDR: Añadir ctiprea (5)
      -- Cursor per el no previ
      CURSOR c1 IS
         SELECT   tcontra, orden, tatribu, SUM(debe) debe, SUM(haber) haber
             FROM (SELECT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                          DECODE(d.catribu,
                                 1, 1,
                                 5, 2,
                                 3, 3,
                                 6, 4,
                                 4, 5,
                                 7, 6,
                                 9, 7,
                                 2, 8,
                                 15, 9,
                                 20, 10,
                                 22, 11,   -- 22678 AVT 28/09/2012
                                 25, 12,
                                 7, 13,
                                 12, 14,
                                 14, 15,
                                 17, 16,
                                 26, 17,
                                 27, 18) orden,
                          d.tatribu, DECODE(m.cdebhab, 2, 0, f_round(m.iimport)) debe,
                          DECODE(m.cdebhab, 2, f_round(m.iimport), 0) haber   -- 26597 AVT 24/04/2013
                     FROM movctatecnica m, detvalores d, contratos c, codicontratos s
                    WHERE m.scontra = c.scontra
                      AND m.nversio = c.nversio
                      AND m.fmovimi >= d_finiefe
                      AND m.fmovimi <= d_ffinefe
                      AND m.ccompani = p_compani
                      AND m.cconcep = d.catribu
                      AND cvalor = 124
                      AND cidioma = v_idioma
                      AND(
                          -- Proporcional
                          (ctiprea IN(1, 2)
                           -- AND d.catribu IN(1, 2, 3, 4, 5, 6, 7, 9, 12, 14, 17, 25, 26, 27))
                           AND d.catribu IN(25))
                          OR
                            -- contracte XL
                          (  ctiprea IN (3,5)
                             -- AND d.catribu IN(12, 5, 17, 20, 22, 25)))   -- 22678: AVT 06/06/2013 ES CANVIA EL CONCEPTE 15 PEL 5
                             AND d.catribu IN(25)))   -- 22678: AVT 06/06/2013 ES CANVIA EL CONCEPTE 15 PEL 5
                      AND m.scontra = s.scontra
                      AND m.cempres = s.cempres
                      AND s.cempres = p_cempres
                      AND ctiprea = p_ctiprea)
            WHERE debe <> 0
               OR haber <> 0
         GROUP BY tcontra, orden, tatribu
         ORDER BY 1, 2;

      -- Bug 0022678 - 26/07/2012 - JMF
      -- Cursor per el previ
      CURSOR c2 IS
         SELECT   tcontra, orden, tatribu, SUM(debe) debe, SUM(haber) haber
             FROM (SELECT m.scontra || '-' || m.nversio || ' ' || c.tcontra tcontra,
                          DECODE(d.catribu,
                                 1, 1,
                                 5, 2,
                                 3, 3,
                                 6, 4,
                                 4, 5,
                                 7, 6,
                                 9, 7,
                                 2, 8,
                                 15, 9,
                                 20, 10,
                                 22, 11,   -- 22678 AVT 28/09/2012
                                 25, 12,
                                 7, 13,
                                 12, 14,
                                 14, 15,
                                 17, 16,
                                 26, 17,
                                 27, 18) orden,
                          d.tatribu, DECODE(m.cdebhab, 2, 0, f_round(m.iimport)) debe,   -- 26597 AVT 24/04/2013
                          DECODE(m.cdebhab, 2, f_round(m.iimport), 0) haber
                     FROM movctaaux m, detvalores d, contratos c, codicontratos s
                    WHERE m.scontra = c.scontra
                      AND m.nversio = c.nversio
                      AND m.fmovimi >= d_finiefe
                      AND m.fmovimi <= d_ffinefe
                      AND m.ccompani = p_compani
                      AND m.cconcep = d.catribu
                      AND cvalor = 124
                      AND cidioma = v_idioma
                      AND(
                          -- Proporcional
                          (ctiprea IN(1, 2)
                           --AND d.catribu IN(1, 2, 3, 4, 5, 6, 7, 9, 12, 14, 17, 25, 26, 27))
                           AND d.catribu IN(25))
                          OR
                            -- contracte XL
                          (  ctiprea IN(3,5)
                             --AND d.catribu IN(12, 5, 17, 20, 22, 25)))   -- 22678: AVT 06/06/2013 ES CANVIA EL CONCEPTE 15 PEL 5
                             AND d.catribu IN(25)))   -- 22678: AVT 06/06/2013 ES CANVIA EL CONCEPTE 15 PEL 5
                      AND m.scontra = s.scontra
                      AND m.cempres = s.cempres
                      AND s.cempres = p_cempres
                      AND ctiprea = p_ctiprea)
            WHERE debe <> 0
               OR haber <> 0
         GROUP BY tcontra, orden, tatribu
         ORDER BY 1, 2;
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Cuenta técnica reserva siniestro
--------------------------------------------------------------------------
--------------------------------------------------------------------------
      v_ntraza := 1040;
      v_txt := NULL;

      IF p_compani IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF p_cidioma IS NULL THEN
        v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1047;
      d_finiefe := TO_DATE(LPAD(TO_CHAR(p_finiefe), 8, '0'), 'ddmmyyyy');
      v_ntraza := 1053;
      d_ffinefe := TO_DATE(LPAD(TO_CHAR(p_ffinefe), 8, '0'), 'ddmmyyyy');
      v_txt := NULL;
      n_primera := 0;
      n_total_debe := 0;
      n_total_haber := 0;

      IF NVL(p_cprevio, 0) = 0 THEN
         FOR f1 IN c1 LOOP
            IF n_primera = 1 THEN
               v_txt := v_txt || ' union';
            END IF;

            n_primera := 1;
            v_txt := v_txt || ' select ' || f1.orden || ', ' || CHR(39) || f1.tcontra
                     || CHR(39) || '||' || CHR(39) || v_sep || CHR(39) || '||' || CHR(39)
                     || f1.tatribu || CHR(39) || '||' || CHR(39) || v_sep || CHR(39) || '||'
                     || CHR(39) || f1.debe || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
                     || '||' || CHR(39) || f1.haber || CHR(39) || '||' || CHR(39) || v_sep
                     || CHR(39) || ' linea from dual';
            n_total_debe := n_total_debe + f1.debe;
            n_total_haber := n_total_haber + f1.haber;
         END LOOP;
      ELSE
         FOR f2 IN c2 LOOP
            IF n_primera = 1 THEN
               v_txt := v_txt || ' union';
            END IF;

            n_primera := 1;
            v_txt := v_txt || ' select ' || f2.orden || ', ' || CHR(39) || f2.tcontra
                     || CHR(39) || '||' || CHR(39) || v_sep || CHR(39) || '||' || CHR(39)
                     || f2.tatribu || CHR(39) || '||' || CHR(39) || v_sep || CHR(39) || '||'
                     || CHR(39) || f2.debe || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
                     || '||' || CHR(39) || f2.haber || CHR(39) || '||' || CHR(39) || v_sep
                     || CHR(39) || ' linea from dual';
            n_total_debe := n_total_debe + f2.debe;
            n_total_haber := n_total_haber + f2.haber;
         END LOOP;
      END IF;

      IF n_primera = 0 THEN
         v_txt := 'select 0, null linea from dual ';
      END IF;

      v_txt := v_txt || ' union select 98, ' || 'null' || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) || 'Total' || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) || n_total_debe || CHR(39) || '||' || CHR(39) || v_sep
              || CHR(39) || '||' || CHR(39) || n_total_haber || CHR(39) || '||' || CHR(39)
               || v_sep || CHR(39) || ' linea from dual';
      v_txt := v_txt || ' union select 99, ' || 'null' || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) || 'SALDO' || CHR(39) || '||' || CHR(39) || v_sep || CHR(39)
               || '||' || CHR(39) ||(n_total_haber - n_total_debe) || CHR(39) || '||'
               || CHR(39) || v_sep || CHR(39) || '||' || CHR(39) || '0' || CHR(39) || '||'
               || CHR(39) || v_sep || CHR(39) || ' linea from dual';
      v_txt := 'select linea from (' || v_txt || ')';
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00505_detreservassini;
-- FI BUG 25373 - FAL - 18/10/2013


   --INICIO IAXIS 4900  I.R.D
 /******************************************************************************************
     Descripción: Función que genera la cabecera del reporte Reserva_sin_rea_facult.csv
   ******************************************************************************************/
  
   FUNCTION f_00546_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00546_CAB';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' f=' || p_ffinefe ||  ' i='
            || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
   BEGIN
      v_ntraza := 1000;
      v_txt := NULL;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

        SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1030;
      v_txt := CHR(10);

      IF p_compani IS NULL THEN
         v_ntraza := 1035;
         v_txt := v_txt || CHR(10);
      ELSE
         v_ntraza := 1040;

         SELECT f_axis_literales(9900914, v_idioma) || MAX(c.tcompani)
           INTO v_aux
           FROM companias c
          WHERE c.ccompani = p_compani;

         v_ntraza := 1045;
         
         
         v_txt := v_txt || v_aux;
      END IF;

      v_ntraza := 1050;
      v_txt := v_txt || CHR(10) || f_axis_literales(105280, v_idioma) || ' '
               || TO_DATE(LPAD(p_ffinefe, 8, '0'), 'ddmmyyyy') ;
             
      v_ntraza := 1055;
                     
      v_txt := v_txt || ' ' || f_axis_literales(9000632, v_idioma) || ': ';

            
      v_txt := v_txt || CHR(10) || CHR(10);
      v_ntraza := 1060;
      v_txt := v_txt || f_axis_literales(104813, v_idioma) || v_sep
               ||   -- Contrato
                  f_axis_literales(9000609, v_idioma) || v_sep
               ||   -- Tramo
                  f_axis_literales(9000600, v_idioma) || v_sep
               ||   -- Compa-ia
                  f_axis_literales(800279, v_idioma) || v_sep
               ||   -- Nm. siniestro                                                   
                  f_axis_literales(801256, v_idioma) || v_sep
               ||   -- F.Ocurrencia
                  f_axis_literales(801260, v_idioma) || v_sep
               ||   -- F.Apertura
                  f_axis_literales(100624, v_idioma) || v_sep
               ||   -- Poliza
                  f_axis_literales(110994, v_idioma) || v_sep
               ||   -- Garanta
                   ' Total_Reserva ' || v_sep
               ||   
                    ' % Cesion ' || v_sep
               ||
                   ' Valor_Reserva_Ced' || v_sep
               ||  
                  f_axis_literales(104818, v_idioma) || v_sep
               ||  -- % Participacion
                   'Reserva_Participacion'  || v_sep
               ||
                  f_axis_literales(108645, v_idioma);  
                   --  Moneda;

      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00546_cab;



   /******************************************************************************************
     Descripción: Función que genera el detalle del reporte Reserva_sin_rea_facult.csv
   ******************************************************************************************/

   FUNCTION f_00546_det(
     p_compani IN NUMBER DEFAULT NULL,
     p_cempres IN NUMBER DEFAULT NULL,
     p_ffinefe IN VARCHAR2 DEFAULT NULL,
     p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_REA.F_00546_DET';
      v_tparam       VARCHAR2(1000)
         := ' c=' || p_compani || ' e=' || p_cempres || ' f=' || p_ffinefe || ' i='
            || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_ffinefe      VARCHAR2(100);
      --v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(5) := CHR(39) || ';' || CHR(39);
      n_primera      NUMBER(1);
   
       
   BEGIN

-- INFORME .- Reserva de siniestros reaseguro facultativo

      v_ntraza := 1040;
      v_txt := NULL;

      IF p_compani IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_ntraza := 1050;
      v_ffinefe := LPAD(p_ffinefe, 8, '0');
      v_ntraza := 1053;
      v_ffinefe := 'to_date(' || CHR(39) || v_ffinefe || CHR(39) || ',''ddmmyyyy'')';
      v_ntraza := 1055;
          
     
      
     v_txt := 
         ' SELECT l.scontra || ''-'' || l.nversio || '' '' || s.tcontra||' || v_sep2
         || ' ||ff_desvalorfijo(105,' || v_idioma || ',l.ctramo) ||' || v_sep2
         || ' ||o.tcompani||pac_md_rea.f_compania_cutoff(o.ccompani, SYSDATE)||' || v_sep2 
         || ' ||l.nsinies||' || v_sep2 
         || ' ||n.fsinies||' || v_sep2 
         || ' || (select p.falta from sin_siniestro p where p.nsinies = l.nsinies)||' || v_sep2
         || ' ||l.npoliza||' || v_sep2
         || ' ||l.cgarant||' || v_sep2
         || ' ||   (select (s.ireserva) from sin_tramita_reserva s where s.NMOVRES = (select max(i.nmovres) from sin_tramita_reserva i
                    where i.nsinies = s.nsinies) and s.nsinies = l.nsinies  and s.ireserva <> 0 ) || ' || v_sep2           
         || ' ||  l.pporcen ||'|| v_sep2          
         || ' || (((select (n.ireserva) from sin_tramita_reserva n where n.NMOVRES = (select max(o.nmovres) from sin_tramita_reserva o
                    where o.nsinies = n.nsinies) and n.nsinies = l.nsinies) * l.pporcen) / 100)||' || v_sep2           
         || ' || abs(c.pcesion) ||' || v_sep2
         || ' || (((((select (f.ireserva) from sin_tramita_reserva f where f.NMOVRES = (select max(e.nmovres) from sin_tramita_reserva e
                    where e.nsinies = f.nsinies  ) and f.nsinies = l.nsinies  ) * l.pporcen) / 100) * c.pcesion ) /100) ||' || v_sep2
         || '|| em.tmoneda || ' || v_sep2 
         || ' linea'
         || ' FROM reaseguro l, cuadroces c, contratos s, companias o, codicontratos cc, eco_desmonedas em,  sin_siniestro n'
         || ' WHERE l.cempres = ' || p_cempres || ' AND fcierre = ' || v_ffinefe;

      IF p_compani IS NOT NULL THEN
         v_txt := v_txt || ' AND l.ccompani = ' || p_compani;
      END IF;

      v_txt := v_txt || '      AND l.scontra = s.scontra' || '      AND l.nversio = s.nversio'
                     || '      AND l.scontra = c.scontra' || '      AND l.nversio = c.nversio'
               || '      AND l.ctramo = c.ctramo'   || '      AND l.ccompani = c.ccompani' 
               || '      AND l.ccompani = o.ccompani'  || '      and cc.scontra = s.scontra' 
               || '      and em.cmoneda = cc.cmoneda'  || '   and l.nsinies = n.nsinies' 
               || '      and (l.sidepag = (select max( s.sidepag) from reaseguro s where s.nsinies = l.nsinies ))'
               || '      and (l.sidepag = (select max(n.sidepag) from sin_tramita_reserva n where n.nsinies = l.nsinies and n.ireserva <> 0))'
               || '      and em.cidioma = ' || v_idioma
               || ' ORDER BY l.npoliza, l.nsinies, l.scontra, l.nversio, l.ctramo, l.cgarant';
     
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00546_det;


END PAC_INFORMES_REA;