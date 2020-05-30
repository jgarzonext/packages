--------------------------------------------------------
--  DDL for Package Body PAC_INFORMES_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_INFORMES_SIN" IS
/******************************************************************************
   NOMBRE:      pac_informes_sin


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/03/2012   JMF              0021662 LCOL_S001-SIN - Excel de movimientos económicos
   2.0        18/07/2012   JMF              0022790: MDP_S001-SIN - Resumen de reservas, pagos y recobros

******************************************************************************/
   v_txt          VARCHAR2(32000);

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Resumen_Siniestro.csv
     Paràmetres entrada: - p_nsinies     -> Siniestro
                         - p_cidioma     -> Idioma
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021662 - 14/03/2012 - JMF
   FUNCTION f_00520_cab(p_nsinies IN NUMBER DEFAULT NULL, p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_SIN.F_00520_CAB';
      v_tparam       VARCHAR2(1000) := ' s=' || p_nsinies || ' i=' || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_aux          VARCHAR2(500);
      -- Bug 0022790 - 18/07/2012 - JMF
      v_contatramte  NUMBER;
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
      v_ntraza := 1060;
      v_txt := v_txt || f_axis_literales(101006, v_idioma) || v_sep   -- Fecha movimiento
               || f_axis_literales(102790, v_idioma) || v_sep   -- Hora:
               || f_axis_literales(9001954, v_idioma) || v_sep   -- Nº movimiento
                                                              ;

      SELECT COUNT(DISTINCT c.ctramte)
        INTO v_contatramte
        FROM sin_siniestro a, seguros b, sin_prod_tramite c
       WHERE a.nsinies = p_nsinies
         AND b.sseguro = a.sseguro
         AND c.sproduc = b.sproduc;

      IF v_contatramte > 1 THEN
         v_txt := v_txt || f_axis_literales(9901991, v_idioma) || v_sep;   -- Trámites
      END IF;

      v_txt := v_txt || f_axis_literales(9903441, v_idioma) || v_sep   -- Nº Trámite
               || f_axis_literales(9903442, v_idioma) || v_sep   -- Trámite
               || f_axis_literales(9901195, v_idioma) || v_sep   -- Tipo
               || f_axis_literales(9001155, v_idioma) || v_sep   --  Tipo Reserva
               || f_axis_literales(9902296, v_idioma) || v_sep   -- Tipo de Gasto
               || f_axis_literales(110994, v_idioma) || v_sep   -- Amparo
               || f_axis_literales(9900791, v_idioma) || v_sep   -- Imp. Pago
               || f_axis_literales(9903443, v_idioma) || v_sep   -- Imp. Deducible
               || f_axis_literales(9900792, v_idioma) || v_sep   -- Imp. Recobro
               || f_axis_literales(9903445, v_idioma) || v_sep   -- Res. Disponible
               || f_axis_literales(9903446, v_idioma) || v_sep   -- Res. Pendiente
               || f_axis_literales(9000909, v_idioma) || v_sep   -- Destinatario
               || f_axis_literales(9903447, v_idioma) || v_sep   -- Perjudicado
               || f_axis_literales(9903137, v_idioma) || v_sep   -- Mediador
               || f_axis_literales(9001326, v_idioma) || v_sep   --  Estado Pago
               || f_axis_literales(9902938, v_idioma) || v_sep   -- Forma de Pago
               || f_axis_literales(9902948, v_idioma) || v_sep   --  Usuario
                                                              ;
      v_ntraza := 1070;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_00520_cab;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Resumen_Siniestro.csv
     Paràmetres entrada: - p_nsinies     -> Siniestro
                         - p_cidioma     -> Idioma
     return:             select detalle
   ******************************************************************************************/
   -- Bug 0021662 - 14/03/2012 - JMF
   FUNCTION f_00520_det(p_nsinies IN NUMBER DEFAULT NULL, p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_SIN.F_00520_DET';
      v_tparam       VARCHAR2(1000) := ' s=' || p_nsinies || ' i=' || p_cidioma;
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(10) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_idioma       NUMBER;
      -- Bug 0022790 - 18/07/2012 - JMF
      v_contatramte  NUMBER;
   BEGIN
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- INFORME .- Listado resumen siniestro
--------------------------------------------------------------------------
--------------------------------------------------------------------------
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

      v_ntraza := 1040;
      v_txt := NULL;
      v_ntraza := 1055;
      v_txt := 'select to_char(c.fmovres,''dd/mm/yyyy'') ' || v_sep2
               || '       to_char(c.fmovres,''hh24:mi'') ' || v_sep2 || '       c.nmovres '
               || v_sep2;

      SELECT COUNT(DISTINCT c.ctramte)
        INTO v_contatramte
        FROM sin_siniestro a, seguros b, sin_prod_tramite c
       WHERE a.nsinies = p_nsinies
         AND b.sseguro = a.sseguro
         AND c.sproduc = b.sproduc;

      IF v_contatramte > 1 THEN
         v_txt :=
            v_txt || ' (select max(c1.ttramite)'
            || '  from   sin_tramite b1, sin_destramite c1'
            || '  where  b1.nsinies=d.nsinies and b1.ntramte=d.ntramte and c1.CTRAMTE=b1.CTRAMTE and c1.cidioma=x.idi'
            || ' ) ' || v_sep2;
      END IF;

      v_txt :=
         v_txt || '       c.ntramit ' || v_sep2
         || '       (select max(ff_desvalorfijo(800,x.idi,d1.CTIPTRA)) from sin_codtramitacion d1 where d1.CTRAMIT=d.CTRAMIT)'
         || v_sep2
         || '       NVL( ff_desvalorfijo(2, x.idi, f.ctippag), f_axis_literales(9001408, x.idi) ) '
         || v_sep2 || '       ff_desvalorfijo(322, x.idi, c.ctipres) ' || v_sep2
         || '       ff_desvalorfijo(1047, x.idi, c.ctipgas) ' || v_sep2
         || '       (select max(e.tgarant) from garangen e where e.cgarant=c.cgarant and e.cidioma=x.idi) '
         || v_sep2 || '       decode(j.nvalpar,1,c.ipago_moncia,c.ipago) ' || v_sep2
         || '       null ' || v_sep2
         || '       decode(j.nvalpar,1,c.irecobro_moncia,c.irecobro) ' || v_sep2
         || '       null ' || v_sep2
         || '       decode(j.nvalpar,1,c.ireserva_moncia,c.ireserva) ' || v_sep2
         || '       f_nombre (f.sperson, 1, null) ' || v_sep2 || '       rtrim( '
         || '        (select  h.tnombre||'' ''||h.tapelli1||'' ''||h.tapelli2'
         || '        from   sin_tramita_personasrel h'
         || '        where  h.NSINIES=c.NSINIES and h.NTRAMIT=c.NTRAMIT'
         || '        and    h.npersrel=1' || '        )' || '        ||''   ''|| '
         || '        (select  h.tnombre||'' ''||h.tapelli1||'' ''||h.tapelli2'
         || '        from   sin_tramita_personasrel h'
         || '        where  h.NSINIES=c.NSINIES and h.NTRAMIT=c.NTRAMIT'
         || '        and    h.npersrel=2' || '        )' || '        ||''   ''|| '
         || '        (select  h.tnombre||'' ''||h.tapelli1||'' ''||h.tapelli2'
         || '        from   sin_tramita_personasrel h'
         || '        where  h.NSINIES=c.NSINIES and h.NTRAMIT=c.NTRAMIT'
         || '        and    h.npersrel=3' || '        )' || '        ) ' || v_sep2
         || '        F_DESAGENTE_T( nvl(b.cagente,a.cagente) ) ' || v_sep2
         || '        ff_desvalorfijo(800057, x.idi, gx.CESTPAG) ' || v_sep2
         || '        ff_desvalorfijo(813, x.idi, f.cforpag) ' || v_sep2
         || '        gx.cusualt ' || '       linea'
         || ' from  seguros a, sin_siniestro b, sin_tramita_reserva c, sin_tramitacion d'
         || '       , sin_tramita_pago f' || '       , ('
         || '         select g.SIDEPAG, g.CESTPAG, g.CUSUALT'
         || '         from   sin_tramita_movpago g'
         || '         where g.NMOVPAG=(select max(g1.NMOVPAG) from sin_tramita_movpago g1 where g1.sidepag=g.sidepag)'
         || '        ) gx' || ', parempresas j' || ', (select ' || v_idioma
         || ' idi from  dual) x' || ' where b.nsinies=' || p_nsinies
         || ' and   j.cempres(+)=a.cempres and j.cparam(+)=''MULTIMONEDA'' '
         || ' and   b.sseguro=a.sseguro' || ' and   c.nsinies=b.nsinies'
         || '  AND   (c.ntramit, c.ctipres, nvl(c.cgarant,-1), c.nmovres)'
         || '        in (select ntramit, ctipres, nvl(cgarant,-1), max(nmovres)'
         || '            from sin_tramita_reserva where nsinies = ' || p_nsinies
         || '            group by ntramit, ctipres, cgarant)'
         || ' and   d.NSINIES=c.nsinies and d.NTRAMIT=c.NTRAMIT'
         || ' and   f.SIDEPAG(+)=c.SIDEPAG' || ' and   gx.SIDEPAG(+)=c.sidepag'
         || ' ORDER BY d.ntramte, d.ntramit, c.CTIPRES, c.cgarant';
      v_ntraza := 9999;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_00520_det;
END pac_informes_sin;

/

  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_SIN" TO "PROGRAMADORESCSI";
