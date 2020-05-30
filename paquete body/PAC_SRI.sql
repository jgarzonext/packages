--------------------------------------------------------
--  DDL for Package Body PAC_SRI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SRI" IS
    /******************************************************************************
      NOMBRE:      PAC_SRI
      PROP¿SITO:   Preparaci¿n para env¿o de datos al SRI
      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.1        27/04/2016    jdelrio          1. Creaci¿n del package.
      2.0       25/08/2016      JAVENDANO       CONF-236: Par¿metros fecha de archivado, eliminaci¿n y caducidad de los documentos
   ******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   --------------------------------------------------------------------------------------Funcion que calcula el d¿gito de verificaci¿n
   FUNCTION f_digito_verificacion(pcadena IN VARCHAR2)
      RETURN NUMBER IS
      digitos        VARCHAR2(6) := '765432';
      leng           NUMBER;
      mult           NUMBER := 1;
      suma           NUMBER := 0;
   BEGIN
      IF LENGTH(pcadena) = 48 THEN
         leng := LENGTH(pcadena);

         FOR a IN 1 .. leng LOOP
            suma := suma +(SUBSTR(pcadena, a, 1) * SUBSTR(digitos, mult, 1));
            mult := mult + 1;

            IF mult > 6 THEN
               mult := 1;
            END IF;
         END LOOP;

         suma := MOD(suma, 11);
         suma := 11 - suma;

         IF suma = 11 THEN
            suma := 0;
         ELSIF suma = 10 THEN
            suma := 1;
         END IF;
      END IF;

      RETURN suma;
   END f_digito_verificacion;

   --------------------------------------------------------------------------------------Funcion que llena la informaci¿n para enviar el xml al sri
   FUNCTION p_envio_sri(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctipocomprobante IN NUMBER)
      RETURN NUMBER IS
      vfemisio       DATE;
      vsperson       NUMBER;
      vspersoncontrib NUMBER;
      vcagente       NUMBER;
      vcagentepadre  NUMBER;
      ventorno       NUMBER := 1;
      perror         VARCHAR2(2000);
      vserie1        NUMBER;
      vserie2        NUMBER;
      vruc           VARCHAR2(100);
      vruccontrib    VARCHAR2(100);
      vtipoide       NUMBER;
      vsecuencial    NUMBER;
      v_clave        VARCHAR2(49);
      v_clavesindigito VARCHAR2(48);
      vtserie        VARCHAR2(6);
      vdigver        NUMBER;
      vcestado       NUMBER;
      vnumerr        NUMBER;
      vsinterf       NUMBER;
      l_refcursor    sys_refcursor;
      vpasexec       NUMBER := 1;
      vcsituac       NUMBER;
      vguiaremision  VARCHAR2(20);
      viprinet       NUMBER := 0;
      vipridev       NUMBER := 0;
      vprimasindemi           NUMBER := 0;
      viimpuesto     NUMBER := 0;
      viva           NUMBER(10,2) := 0;
      vivademi           NUMBER(10,2) := 0;
      vivaprima           NUMBER(10,2) := 0;
      vivascvs           NUMBER(10,2) := 0;
      vivassc           NUMBER(10,2) := 0;
      viscvs NUMBER(10,2) := 0;
      vissc NUMBER(10,2) := 0;
      videmi  NUMBER(10,2) := 0;
      vsbs           NUMBER := 0;
      vicampesino    NUMBER := 0;
      videscuento    NUMBER := 0;
      vfemisiooriginal DATE;
      vmotivo        VARCHAR2(20);
      vnfactura varchar2(20);
      vpdto          NUMBER;
      vtipocomprobante NUMBER := 1;
      vctipocomprobante NUMBER := pctipocomprobante;
      vanulac NUMBER;
      vrespuesta     VARCHAR2(100);
      vrespuesta2     VARCHAR2(100);
      vcmotmov    NUMBER;
      vctiprec NUMBER;
      vmensajes      CLOB;
      vcrespue NUMBER;
      vparam         VARCHAR2(1000)
         := 'pcempres:' || pcempres || ' - psseguro:' || psseguro || ' - pnmovimi:'
            || pnmovimi || ' - pctipocomprobante:' || pctipocomprobante;
      vctipcol       NUMBER := 0;
      vimporte NUMBER;

      CURSOR c_colectivo(vsseguro IN NUMBER, vnmovimi IN NUMBER) IS
         SELECT *
           FROM detmovsegurocol
          WHERE sseguro_0 = vsseguro
            AND nmovimi_0 = vnmovimi;
   BEGIN
      IF psseguro IS NOT NULL THEN
         vpasexec := 2;

         BEGIN
            SELECT NVL(sr.cestado, -1)
              INTO vcestado
              FROM sri_servrentint sr, movseguro m
             WHERE sr.sseguro = psseguro
               AND m.sseguro = sr.sseguro
               and sr.cestado = 0
               AND m.nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcestado := -1;
         END;

         begin
          begin
          select crespue into vcrespue from pregunpolseg where cpregun = 4817 and sseguro = psseguro and nmovimi = pnmovimi;
            exception when others then
             vcrespue := 0;
          end;

          if vcrespue = 1 then
          select r.ctiprec, v.ipridev into vctiprec, vimporte from recibos r, vdetrecibos v where v.nrecibo = r.nrecibo and r.sseguro = psseguro and r.nmovimi = pnmovimi and r.ctiprec not in (13,15);
          else
          select r.ctiprec, v.ipridev into vctiprec, vimporte from recibos r, vdetrecibos v where v.nrecibo = r.nrecibo and r.sseguro = psseguro and r.nmovimi = pnmovimi;
          end if;

          if NVL(vimporte,0) = 0 then
            --no va sri si no hay recibo
            p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                                 'El recibo generado no tiene prima ' || SQLCODE,
                                 vparam);
            RETURN 0;
          end if;

         exception
         when no_data_found then
          --no va sri si no hay recibo
          p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                                 'No se ha generado recibo ' || SQLCODE,
                                 vparam);
          RETURN 0;
         when others then
          null;
         end;

         if vctiprec <> 9 and pctipocomprobante = 4 then
          --si es suplemento de aumento de capital, creamos factura en vez de nota de credito
          vctipocomprobante := 1;
         elsif vctiprec = 9 then
          vctipocomprobante := 4;
         end if;

         /*Estado en el que se encuentra la factura o nota de cr¿dito.
            0 -Este estado se da cuando creamos por primera vez la factura o nota de cr¿dito y cuando recibimos una recepci¿n err¿nea. Actuaci¿n: Enviar al webservice de recepci¿n.
            1- Recibido
            2-Autorizado ok
         */
         vpasexec := 3;

         --creamos una nueva clave
         SELECT decode(vctipocomprobante,4,f_sysdate,s.femisio), NVL(g.sperson, t.sperson),
                pac_parametros.f_parproducto_n(s.sproduc, 'ENTORNO_SRI') entorno, s.cagente,
                pac_seguros.f_es_col_admin(s.sseguro, 'SEG')
           INTO vfemisio, vspersoncontrib,
                ventorno, vcagente,
                vctipcol
           FROM seguros s, gescobros g, tomadores t
          WHERE s.sseguro = psseguro
            AND t.sseguro = s.sseguro
            AND g.sseguro(+) = s.sseguro
                                        --AND s.creteni = 0
         ;

         vcagentepadre := pac_redcomercial.ff_buscanivelredcom(psseguro, f_sysdate, 3);

         select sperson
         into vsperson
         --from agentes where cagente = vcagente;
         from agentes where cagente = vcagentepadre;

         vpasexec := 4;

         SELECT nnumide
           INTO vruc
           FROM per_personas
          WHERE sperson = vsperson;

          SELECT nnumide, decode(ctipide,63,4,64,4,65,4,66,5,6)
           INTO vruccontrib, vtipoide
           FROM per_personas
          WHERE sperson = vspersoncontrib;

         vpasexec := 5;
         vserie1 := pac_redcomercial.ff_buscanivelredcom(psseguro, f_sysdate, 3);
         vpasexec := 6;

         /*SELECT p.nnumide
           INTO vserie2
           FROM agentes a, per_personas p
          WHERE a.cagente = vcagente
            AND a.sperson = p.sperson;*/

            vserie2 := 100001;

         vpasexec := 7;
         vtserie := LPAD(SUBSTR(vserie1, LENGTH(vserie1) - 2, 3), 3, '0')
                    || LPAD(SUBSTR(vserie2, LENGTH(vserie2) - 2, 3), 3, '0');
         vpasexec := 8;

         SELECT NVL(MAX(nsecuencial), 0)+1
           INTO vsecuencial
           FROM sri_servrentint
          WHERE ctipo = vctipocomprobante
            AND tserie like vtserie;

         vpasexec := 9;

         IF vcestado NOT IN(0, 1) THEN
            v_clavesindigito := LPAD(TO_CHAR(vfemisio, 'ddmmyyyy'), 8, '0')
                                || LPAD(vctipocomprobante, 2, '0') || LPAD(vruc, 13, '0')
                                || ventorno || vtserie || LPAD(vsecuencial, 9, '0')
                                || '123456781';
            vdigver := f_digito_verificacion(v_clavesindigito);
            v_clave := v_clavesindigito || vdigver;
            vpasexec := 10;

            vnfactura := LPAD(SUBSTR(vserie1, LENGTH(vserie1) - 2, 3), 3, '0')
                         || '-'
                         || LPAD(SUBSTR(vserie2, LENGTH(vserie2) - 2, 3), 3, '0')
                         || '-' || LPAD(vsecuencial, 9, '0');

            --insertamos informacion en la tabla de sri
            INSERT INTO sri_servrentint
                        (clave, ctipo, femision, fvencim, cestado, tserie, nsecuencial,
                         sseguro, nmovimi, factura)
                 VALUES (v_clave, vctipocomprobante, vfemisio, NULL, 0, vtserie, vsecuencial,
                         psseguro, pnmovimi, vnfactura);

            COMMIT;
         ELSE
            vpasexec := 11;

            --se trata de una situaci¿n de reenvio.
            SELECT sr.clave, sr.femision, sr.tserie, sr.nsecuencial, sr.factura
              INTO v_clave, vfemisio, vtserie, vsecuencial, vnfactura
              FROM sri_servrentint sr, movseguro m
             WHERE sr.sseguro = psseguro
               AND m.sseguro = sr.sseguro
               AND m.nmovimi = pnmovimi
               and sr.nmovimi = m.nmovimi;
         END IF;

         --es nota de credito, cogemos la factura o nota a modificar:
         IF vctipocomprobante = 4 THEN
            vpasexec := 12;

            --anulaciones modificamos la factura
                 --Importe = Prima Factura * [Tiempo restante al vencimiento/ Tiempo Total P¿liza]
            --pendiente calcular importes
            SELECT factura,
                   iprinet, femision
              INTO vguiaremision,
                   vipridev, vfemisiooriginal
              FROM sri_servrentint
             WHERE sseguro = psseguro
               AND ctipo = 1
               AND nmovimi IN(SELECT MAX(nmovimi)
                                FROM sri_servrentint
                               WHERE ctipo = 1
                                 AND sseguro = psseguro)
               AND cestado in (1, 2);

               update sri_servrentint set facturamod = vguiaremision where clave = v_clave;
               commit;

            select count(1) into vanulac from seguros where sseguro = psseguro and fanulac is not null;

            begin
              select decode(m1.cmotmov,666,(select tmotmov from motmovseg where cidioma = 10 and cmotmov = (select min(cmotmov) from detmovseguro where sseguro = s1.sseguro and nmovimi = s1.nmovimi)), m1.tmotmov), m1.cmotmov
              into vmotivo, vcmotmov
              from motmovseg m1, movseguro mv1, sri_servrentint s1
            where s1.sseguro = mv1.sseguro and s1.nmovimi = mv1.nmovimi and mv1.cmotmov = m1.cmotmov and m1.cidioma = 10 and s1.sseguro = psseguro
               and s1.nmovimi = (select max(nmovimi) from movseguro where sseguro = psseguro);
            exception when others then
              vmotivo := 'Modificaci¿n de garant¿as';
            end;

            --if vanulac = 1 then
              --vmotivo := 'Modificaci¿n de garant¿as';
            --end if;

            --tenemos que controlar cuando existen varias facturas para esta p¿liza, se tiene que disminuir el importe de todas las facturas abiertas proporcionalmente a los importes.




         --suplementos modificamos la factura
         --suplemento aumento de prima 355
               --Importe a enviar = Importe Aumento * [Tiempo restante entre Fecha fin de vigencia y Fecha Suplemento]
         --suplemento disminucion de prima 356
               --Importe a enviar = Importe Disminuci¿n * [Tiempo restante entre Fecha fin de vigencia y Fecha Suplemento]
         END IF;

         BEGIN
            vpasexec := 13;

            SELECT crespue
              INTO vpdto
              FROM pregunseg
             WHERE sseguro = psseguro
               AND cpregun = 4955
               AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN OTHERS THEN
               vpdto := 0;
         END;

         --generamos xml
         BEGIN
            --facturas
            IF vctipocomprobante = 1 THEN
               vpasexec := 14;

               IF vctipcol = 1 THEN
                  --si es un colectivo administrado tenemos que calcular los importes de las polizas hijas
                 /* FOR v_cursor IN c_colectivo(psseguro, pnmovimi) LOOP
                     --si el estado contin¿a 0 reenviamos.
                     viprinet := viprinet
                                 + f_detalle_primas(v_cursor.sseguro_cert,
                                                    v_cursor.nmovimi_cert, 1);
                     --viva := viva
                     --        + f_detalle_primas(v_cursor.sseguro_cert, v_cursor.nmovimi_cert,
                     --                           11);

                     vsbs := vsbs
                             + f_detalle_primas(v_cursor.sseguro_cert, v_cursor.nmovimi_cert,
                                                12);
                     vicampesino := vicampesino
                                    + f_detalle_primas(v_cursor.sseguro_cert,
                                                       v_cursor.nmovimi_cert, 13);
                     viimpuesto := viva + vsbs + vicampesino;
                     --viimpuesto := f_detalle_primas(psseguro, pnmovimi, 3);
                     videscuento := videscuento
                                    + f_detalle_primas(v_cursor.sseguro_cert,
                                                       v_cursor.nmovimi_cert, 10)
                                    +(viprinet * vpdto / 100);
                  END LOOP;*/
                  --vamos a buscar el recibo del colectivo y ser¿ el ipridev el campo que necesitaremos
                  begin
                    select sum(abs(ipridev*decode(r.ctiprec,13,-1,1))), sum(abs(idgs*decode(r.ctiprec,13,-1,1))),sum(abs(iarbitr*decode(r.ctiprec,13,-1,1))),sum(abs(iderreg*decode(r.ctiprec,13,-1,1))), sum(abs(iips*decode(r.ctiprec,13,-1,1))) into vipridev, viscvs, vissc, videmi, vivaprima from recibos r, vdetrecibos v where r.sseguro = psseguro and r.nmovimi = pnmovimi and r.nrecibo = v.nrecibo;
                    begin
                    select sum(abs(iconcep*decode(r.ctiprec,13,-1,1))) into vivademi from detrecibos d, recibos r where r.sseguro = psseguro and r.nmovimi = pnmovimi and r.nrecibo = d.nrecibo and cconcep = 86;
                    exception when others then
                    vivademi := 0;
                    end;

                    viva := nvl(vivaprima,0)+nvl(vivademi,0);
                    viprinet := vipridev + viscvs + vissc + videmi;
                  exception when others then
                   p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                                 'Error al recuperar ipridev, ' || '-' || SQLCODE,
                                 vparam || ' - ' || perror || ' -vsinterf:' || vsinterf);
                  end;

                  --calculamos el iva sobre el iprinet totalizado
                  --viva := viprinet * 0.14;
               ELSE
                  /*viprinet := f_detalle_primas(psseguro, pnmovimi, 1);
                  --viva := f_detalle_primas(psseguro, pnmovimi, 11);
                  --calculamos el iva sobre el iprinet totalizado
                  viva := viprinet * 0.14;
                  vsbs := f_detalle_primas(psseguro, pnmovimi, 12);
                  vicampesino := f_detalle_primas(psseguro, pnmovimi, 13);
                  viimpuesto := viva + vsbs + vicampesino;
                  --viimpuesto := f_detalle_primas(psseguro, pnmovimi, 3);
                  videscuento := f_detalle_primas(psseguro, pnmovimi, 10)
                                 +(viprinet * vpdto / 100);*/
                                 --vamos a buscar el recibo del colectivo y ser¿ el ipridev el campo que necesitaremos
                  begin
                  select sum(abs(ipridev*decode(r.ctiprec,13,-1,1))), sum(abs(idgs*decode(r.ctiprec,13,-1,1))),sum(abs(iarbitr*decode(r.ctiprec,13,-1,1))),sum(abs(iderreg*decode(r.ctiprec,13,-1,1))), sum(abs(iips*decode(r.ctiprec,13,-1,1))) into vipridev, viscvs, vissc, videmi, vivaprima from recibos r, vdetrecibos v where r.sseguro = psseguro and r.nmovimi = pnmovimi and r.nrecibo = v.nrecibo;
                  begin
                    select sum(abs(iconcep*decode(r.ctiprec,13,-1,1))) into vivademi from detrecibos d, recibos r where r.sseguro = psseguro and r.nmovimi = pnmovimi and r.nrecibo = d.nrecibo and cconcep = 86;
                    exception when others then
                    vivademi := 0;
                    end;
                    viva := nvl(vivaprima,0)+nvl(vivademi,0);
                  viprinet := vipridev + viscvs + vissc + videmi;
                  exception when others then
                   p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                                 'Error al recuperar ipridev, ' || '-' || SQLCODE,
                                 vparam || ' - ' || perror || ' -vsinterf:' || vsinterf);

                  end;
                  --viva := viprinet * 0.14;
               END IF;

               begin
                  vprimasindemi := vipridev + viscvs + vissc;
               exception when others then
                  vprimasindemi := 0;
               end;
               begin
                  vivascvs := vivaprima * (viscvs/vprimasindemi);
               exception when others then
                  vivascvs := 0;
               end;
               begin
                  vivassc := vivaprima * (vissc/vprimasindemi);
               exception when others then
                  vivassc := 0;
               end;
               begin
                  vivaprima := vivaprima * (vipridev/vprimasindemi);
               exception when others then
                  vivaprima := 0;
               end;

               OPEN l_refcursor FOR
                  --infoTributaria
                  SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(s.cempres,'USER_BBDD')) contexto, ventorno ambiente, 1 tipoemision, 'AMA AM¿RICA SA EMPRESA DE SEGUROS' razonsocial,
                         -- 1 tipoemision, f_nombre(tom.sperson, 3) razonsocial,
                         --f_nombre(vsperson, 3) nombrecomercial,
                         'AMA Am¿rica SA' nombrecomercial,
                         (select pe.nnumide from agentes ag, per_personas pe where ag.cagente = pac_redcomercial.ff_buscanivelredcom(s.sseguro, f_sysdate, 0) and pe.sperson = ag.sperson) ruc,
                         v_clave claveacceso,
                         LPAD(vctipocomprobante, 2, '0') coddoc,
                         LPAD(SUBSTR(vserie1, LENGTH(vserie1) - 2, 3), 3, '0') estab,
                         LPAD(SUBSTR(vserie2, LENGTH(vserie2) - 2, 3), 3, '0') ptoemi,
                         LPAD(vsecuencial, 9, '0') secuencial,
                         (select pd.tnomvia || pd.nnumvia || ', ' || pd.tcomple from agentes ag, per_personas pe, per_direcciones pd where ag.cagente = pac_redcomercial.ff_buscanivelredcom(s.sseguro, f_sysdate, 0) and pd.sperson = pe.sperson and pd.cdomici = (select max(cdomici) from per_direcciones where sperson = pe.sperson) and pe.sperson = ag.sperson) dirmatriz,

                         --infoFactura
                         TO_CHAR(vfemisio, 'dd/mm/yyyy') fechaemision,
                         (select tnomvia || nnumvia || ', ' || tcomple from agentes ag, per_personas pe, per_direcciones pd where ag.cagente = pac_redcomercial.ff_buscanivelredcom(s.sseguro, f_sysdate, 0) and pd.sperson = pe.sperson and pd.cdomici = (select max(cdomici) from per_direcciones where sperson = pe.sperson) and pe.sperson = ag.sperson) direstablecimiento,
                         NULL contribuyenteespecial, 'SI' obligadocontabilidad,
                         LPAD(vtipoide,2,'0') tipoidentificacioncomprador,
                         DECODE(vctipocomprobante,4,LPAD(SUBSTR(vserie1, LENGTH(vserie1) - 2, 3), 3, '0')
                         || '-'
                         || LPAD(SUBSTR(vserie2, LENGTH(vserie2) - 2, 3), 3, '0')
                         || '-' || LPAD(vsecuencial, 9, '0'),'') guiaremision,
                         f_nombre(NVL(g.sperson, tom.sperson),3) razonsocialcomprador,
                         vruccontrib identificacioncomprador,
                         pac_isqlfor.f_domicilio(NVL(g.sperson, tom.sperson), tom.cdomici) direccioncomprador,
                         replace(viprinet,',','.') totalsinimpuestos, replace(videscuento,',','.') totaldescuento,
                                                                                --totalConImpuestos
                                                                                --totalImpuesto
                         2 codigo, 3 codigoporcentaje, replace(vipridev,',','.') baseimponible,
                         replace(viva,',','.') valor, 0 propina, replace((viprinet + viva),',','.') importetotal,
                         14 tarifa, --pac_monedas.f_cmoneda_t(cmoneda) moneda,
                         'DOLAR' moneda,

                         --detalles
                         'PRIMA' codigoprincipal, DECODE (s.cramo,21,'RCP','OTRO') codigoauxiliar, 'PRIMA DE SEGUROS' descripcion,
                         1 cantidad, replace(vipridev,',','.') preciounitario, 0 descuento,
                         replace(vipridev,',','.') preciototalsinimpuesto, replace(vivaprima,',','.') valor1,
                         '' detadicional1,

                         'SCVS' codigoprincipal2, DECODE (s.cramo,21,'RCP','OTRO') codigoauxiliar2, 'SUPERINTENDENCIA COMPA¿¿AS, VALORES Y SEGUROS' descripcion2,
                         1 cantidad2, replace(vISCVS,',','.') preciounitario2, 0 descuento2,
                         replace(vISCVS,',','.') preciototalsinimpuesto2, replace(vivascvs,',','.') valor2,
                         '3,5%' detadicional21,

                         'SSC' codigoprincipal3, DECODE (s.cramo,21,'RCP','OTRO') codigoauxiliar3, 'SEGURO SOCIAL CAMPESINO' descripcion3,
                         1 cantidad3, replace(vISSC,',','.') preciounitario3, 0 descuento3,
                         replace(vISSC,',','.') preciototalsinimpuesto3, replace(vivassc,',','.') valor3,
                         '0,5%' detadicional31,

                         'DEMI' codigoprincipal4, DECODE (s.cramo,21,'RCP','OTRO') codigoauxiliar4, 'DERECHOS DE EMISION' descripcion4,
                         1 cantidad4, replace(vIDEMI,',','.') preciounitario4, 0 descuento4,
                         replace(vIDEMI,',','.') preciototalsinimpuesto4, replace(vivademi,',','.') valor4,
                         '' detadicional41,

                         s.npoliza ||' / '||f_nombre(tom.sperson, 3) campoadicional1,
s.ncertif ||' / '||f_nombre(a.sperson, 3) campoadicional2,
s.nsuplem campoadicional3,
TO_CHAR(m.fefecto, 'dd/mm/yyyy')||'-'||decode(s.frenova, null,TO_CHAR(add_months(s.fefecto,12)-1, 'dd/mm/yyyy'),TO_CHAR(s.frenova - 1 , 'dd/mm/yyyy') ) campoadicional4,
(select tatribu from detvalores where cvalor = 552 and cidioma = 10 and catribu = s.ctipcob)||' / '||(select tatribu from detvalores where cvalor = 17 and cidioma = 10 and catribu = s.cforpag) campoadicional5,
pac_isqlfor.f_domicilio(NVL(g.sperson, tom.sperson), tom.cdomici) campoadicional6,
(select min(tvalcon) from per_contactos where sperson = NVL(g.sperson, tom.sperson) and ctipcon in (1,6) and tvalcon is not null and rownum = 1) campoadicional7,
(select min(tvalcon) from per_contactos where sperson = NVL(g.sperson, tom.sperson) and ctipcon =3 and tvalcon is not null and rownum = 1) campoadicional8

                    FROM seguros s, asegurados a, titulopro t, gescobros g, tomadores tom, movseguro m
                   WHERE s.sseguro = psseguro
                     AND m.nmovimi = pnmovimi
                     AND m.sseguro = s.sseguro
                     AND s.cramo = t.cramo
                     AND s.cmodali = t.cmodali
                     AND s.ctipseg = t.ctipseg
                     AND s.ccolect = t.ccolect
                     AND t.cidioma = f_usu_idioma
                      AND g.sseguro(+) = s.sseguro
                      AND tom.sseguro = s.sseguro
                     AND a.sseguro = s.sseguro;
            ELSE
               vpasexec := 15;
--tenemos que controlar cuando existen varias facturas para esta p¿liza, se tiene que disminuir el importe de todas las facturas abiertas proporcionalmente a los importes.
--hacemos un bucle para cada factura abierta
               IF vctipcol = 1 THEN
                  --si es un colectivo administrado tenemos que calcular los importes de las polizas hijas
                 /* FOR v_cursor IN c_colectivo(psseguro, pnmovimi) LOOP
                     --si el estado contin¿a 0 reenviamos.
                     viprinet := viprinet
                                 + f_detalle_primas(v_cursor.sseguro_cert,
                                                    v_cursor.nmovimi_cert, 1);
                     --viva := viva
                     --        + f_detalle_primas(v_cursor.sseguro_cert, v_cursor.nmovimi_cert,
                     --                           11);
                     vsbs := vsbs
                             + f_detalle_primas(v_cursor.sseguro_cert, v_cursor.nmovimi_cert,
                                                12);
                     vicampesino := vicampesino
                                    + f_detalle_primas(v_cursor.sseguro_cert,
                                                       v_cursor.nmovimi_cert, 13);
                     viimpuesto := viva + vsbs + vicampesino;
                     --viimpuesto := f_detalle_primas(psseguro, pnmovimi, 3);
                     videscuento := videscuento
                                    + f_detalle_primas(v_cursor.sseguro_cert,
                                                       v_cursor.nmovimi_cert, 10)
                                    +(viprinet * vpdto / 100);
                  END LOOP;*/
                  --vamos a buscar el recibo del colectivo y ser¿ el ipridev el campo que necesitaremos
                  begin
                  select abs(ipridev), abs(idgs),abs(iarbitr),abs(iderreg), abs(iips) into vipridev, viscvs, vissc, videmi, vivaprima from recibos r, vdetrecibos v where r.sseguro = psseguro and r.nmovimi = pnmovimi and r.nrecibo = v.nrecibo;
                  begin
                    select sum(abs(iconcep)) into vivademi from detrecibos d, recibos r where r.sseguro = psseguro and r.nmovimi = pnmovimi and r.nrecibo = d.nrecibo and cconcep = 86;
                    exception when others then
                    vivademi := 0;
                    end;
                    viva := nvl(vivaprima,0)+nvl(vivademi,0);
                  viprinet := vipridev + viscvs + vissc + videmi;
                  exception when others then
                   p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                                 'Error al recuperar ipridev, ' || '-' || SQLCODE,
                                 vparam || ' - ' || perror || ' -vsinterf:' || vsinterf);
                  end;

                  --calculamos el iva sobre el iprinet totalizado
                  --viva := viprinet * 0.14;
               ELSE
                  /*viprinet := f_detalle_primas(psseguro, pnmovimi, 1);
                  --viimpuesto := f_detalle_primas(psseguro, pnmovimi, 3);
                  --viva := f_detalle_primas(psseguro, pnmovimi, 11);
                  viva := viprinet * 0.14;
                  vsbs := f_detalle_primas(psseguro, pnmovimi, 12);
                  vicampesino := f_detalle_primas(psseguro, pnmovimi, 13);
                  viimpuesto := viva + vsbs + vicampesino;
                  videscuento := f_detalle_primas(psseguro, pnmovimi, 10)
                                 +(viprinet * vpdto / 100);*/
                --vamos a buscar el recibo del colectivo y ser¿ el ipridev el campo que necesitaremos
                  begin
                  select abs(ipridev), abs(idgs),abs(iarbitr),abs(iderreg), abs(iips) into vipridev, viscvs, vissc, videmi, vivaprima from recibos r, vdetrecibos v where r.sseguro = psseguro and r.nmovimi = pnmovimi and r.nrecibo = v.nrecibo;
                  begin
                    select sum(abs(iconcep)) into vivademi from detrecibos d, recibos r where r.sseguro = psseguro and r.nmovimi = pnmovimi and r.nrecibo = d.nrecibo and cconcep = 86;
                    exception when others then
                    vivademi := 0;
                    end;
                    viva := nvl(vivaprima,0)+nvl(vivademi,0);
                  viprinet := vipridev + viscvs + vissc + videmi;
                  exception when others then
                   p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                                 'Error al recuperar ipridev, ' || '-' || SQLCODE,
                                 vparam || ' - ' || perror || ' -vsinterf:' || vsinterf);
                  end;

                  --calculamos el iva sobre el iprinet totalizado
                  --viva := viprinet * 0.14;

               END IF;

               begin
                  vprimasindemi := vipridev + viscvs + vissc;
               exception when others then
                  vprimasindemi := 0;
               end;
               begin
                  vivascvs := vivaprima * (viscvs/vprimasindemi);
               exception when others then
                  vivascvs := 0;
               end;
               begin
                  vivassc := vivaprima * (vissc/vprimasindemi);
               exception when others then
                  vivassc := 0;
               end;
               begin
                  vivaprima := vivaprima * (vipridev/vprimasindemi);
               exception when others then
                  vivaprima := 0;
               end;

               --nota de credito
               OPEN l_refcursor FOR
                  --infoTributaria
                  SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(s.cempres,'USER_BBDD')) contexto, ventorno ambiente, 1 tipoemision, 'AMA AM¿RICA SA EMPRESA DE SEGUROS' razonsocial,
                         --pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(s.cempres,'USER_BBDD')) contexto, ventorno ambiente, 1 tipoemision, f_nombre(vsperson, 3) razonsocial,
                         --f_nombre(vsperson, 3) nombrecomercial,
                         'AMA Am¿rica SA' nombrecomercial,
                         pac_isqlfor.f_dni(NULL, NULL, vsperson) ruc, v_clave claveacceso,
                         LPAD(vctipocomprobante, 2, '0') coddoc,
                         LPAD(SUBSTR(vserie1, LENGTH(vserie1) - 2, 3), 3, '0') estab,
                         LPAD(SUBSTR(vserie2, LENGTH(vserie2) - 2, 3), 3, '0') ptoemi,
                         LPAD(vsecuencial, 9, '0') secuencial,
                         (select pd.tnomvia || pd.nnumvia || ', ' || pd.tcomple from agentes ag, per_personas pe, per_direcciones pd where ag.cagente = pac_redcomercial.ff_buscanivelredcom(s.sseguro, f_sysdate, 0) and pd.sperson = pe.sperson and pd.cdomici = (select max(cdomici) from per_direcciones where sperson = pe.sperson) and pe.sperson = ag.sperson) dirmatriz,

                         --infoNotaCredito
                         TO_CHAR(vfemisio, 'dd/mm/yyyy') fechaemision,
                         (select tnomvia || nnumvia || ', ' || tcomple from agentes ag, per_personas pe, per_direcciones pd where ag.cagente = pac_redcomercial.ff_buscanivelredcom(s.sseguro, f_sysdate, 0) and pd.sperson = pe.sperson and pd.cdomici = (select max(cdomici) from per_direcciones where sperson = pe.sperson) and pe.sperson = ag.sperson) direstablecimiento,
                         NULL contribuyenteespecial, 'SI' obligadocontabilidad,
                         LPAD(vtipoide,2,'0') tipoidentificacioncomprador,
                         pac_isqlfor.f_persona(psseguro, 2, NULL) razonsocialcomprador,
                         vruccontrib identificacioncomprador,
                         '01' coddocmodificado, vguiaremision numdocmodificado,
                         TO_CHAR(vfemisiooriginal, 'dd/mm/yyyy') fechaemisiondocsustento,
                         replace(viprinet,',','.') totalsinimpuestos, replace((viprinet + viva),',','.') valormodificacion,
                         pac_monedas.f_cmoneda_t(cmoneda) moneda,
                                                                 --totalConImpuestos
                                                                 --totalImpuesto
                         2 codigo, 3 codigoporcentaje, replace(viprinet,',','.') baseimponible, replace(viva,',','.') valor,
                         vmotivo motivo, replace((viprinet + viva),',','.') importetotal, 14 tarifa,
                         --pac_monedas.f_cmoneda_t(cmoneda) moneda,
                         'DOLAR' moneda,

                                                                  --detalles
                         'PRIMA' codigoprincipal, DECODE (s.cramo,21,'RCP','OTRO') codigoauxiliar, 'PRIMA DE SEGUROS' descripcion,
                         1 cantidad, replace(vipridev,',','.') preciounitario, 0 descuento,
                         replace(vipridev,',','.') preciototalsinimpuesto, replace(vivaprima,',','.') valor1,
                         '' detadicional1,

                         'SCVS' codigoprincipal2, DECODE (s.cramo,21,'RCP','OTRO') codigoauxiliar2, 'SUPERINTENDENCIA COMPA¿IAS' descripcion2,
                         1 cantidad2, replace(vISCVS,',','.') preciounitario2, 0 descuento2,
                         replace(vISCVS,',','.') preciototalsinimpuesto2, replace(vivascvs,',','.') valor2,
                         '3,5%' detadicional21,

                         'SSC' codigoprincipal3, DECODE (s.cramo,21,'RCP','OTRO') codigoauxiliar3, 'SEGURO SOCIAL CAMPESINO' descripcion3,
                         1 cantidad3, replace(vISSC,',','.') preciounitario3, 0 descuento3,
                         replace(vISSC,',','.') preciototalsinimpuesto3, replace(vivassc,',','.') valor3,
                         '0,5%' detadicional31,

                         'DEMI' codigoprincipal4, DECODE (s.cramo,21,'RCP','OTRO') codigoauxiliar4, 'DERECHOS DE EMISION' descripcion4,
                         1 cantidad4, replace(vIDEMI,',','.') preciounitario4, 0 descuento4,
                         replace(vIDEMI,',','.') preciototalsinimpuesto4, replace(vivademi,',','.') valor4,
                         '' detadicional41,

                         s.npoliza ||' / '||f_nombre(tom.sperson, 3) campoadicional1,
s.ncertif ||' / '||f_nombre(a.sperson, 3) campoadicional2,
s.nsuplem campoadicional3,
TO_CHAR(m.fefecto, 'dd/mm/yyyy')||'-'||decode(s.frenova, null,TO_CHAR(add_months(s.fefecto,12)-1, 'dd/mm/yyyy'),TO_CHAR(s.frenova -1 , 'dd/mm/yyyy')) campoadicional4,
(select tatribu from detvalores where cvalor = 552 and cidioma = 10 and catribu = s.ctipcob)||' / '||(select tatribu from detvalores where cvalor = 17 and cidioma = 10 and catribu = s.cforpag) campoadicional5,
pac_isqlfor.f_domicilio(NVL(g.sperson, tom.sperson), tom.cdomici) campoadicional6,
(select min(tvalcon) from per_contactos where sperson = NVL(g.sperson, tom.sperson) and ctipcon in (1,6) and tvalcon is not null and rownum = 1) campoadicional7,
(select min(tvalcon) from per_contactos where sperson = NVL(g.sperson, tom.sperson) and ctipcon =3 and tvalcon is not null and rownum = 1) campoadicional8

                    FROM seguros s, asegurados a, titulopro t, gescobros g, tomadores tom, movseguro m
                   WHERE s.sseguro = psseguro
                     AND m.nmovimi = pnmovimi
                     AND m.sseguro = s.sseguro
                     AND s.cramo = t.cramo
                     AND s.cmodali = t.cmodali
                     AND s.ctipseg = t.ctipseg
                     AND s.ccolect = t.ccolect
                     AND t.cidioma = f_usu_idioma
                     AND g.sseguro(+) = s.sseguro
                     AND tom.sseguro = s.sseguro
                     AND a.sseguro = s.sseguro;
            END IF;

            vpasexec := 16;

            IF vctipocomprobante <> 1 THEN
               vtipocomprobante := 2;
            ELSE
               vtipocomprobante := vctipocomprobante;
            END IF;

            UPDATE sri_servrentint
                  SET iprinet = vipridev,
                      iimpuesto = viva,
                      idescuento = videscuento,
                      ISCVS = viscvs,
                      ISSC = vissc,
                      IDEMI = videmi
                WHERE clave = v_clave;
                COMMIT;

            vpasexec := 17;
            vnumerr := pac_con.f_connect_estandar(pcempres, psseguro, pnmovimi, vsinterf,
                                                  perror, XMLTYPE(l_refcursor).getclobval,
                                                  vtipocomprobante, 'iaxcon_recep_comp',
                                                  'I050');

            IF (vnumerr = 0) THEN
               vpasexec := 18;

               UPDATE sri_servrentint
                  SET sinterf_r = vsinterf
                WHERE clave = v_clave;

               COMMIT;
            ELSE
              UPDATE sri_servrentint
                  SET sinterf_r = vsinterf,
                  out_r = perror
                WHERE clave = v_clave;

                COMMIT;
              p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                                 'Error en el connect ' || vnumerr || '-' || SQLCODE,
                                 vparam || ' - ' || perror || ' -vsinterf:' || vsinterf);
              RETURN 1;
            END IF;

            vrespuesta := pac_con.f_tag(vsinterf, 'estado', 'TMENINHOST');

            --problemas de tmenout la primera vez, pero entra la respuesta, en el reproceso debe dar por recibidas las que den clave duplicada
            if vrespuesta = 'DEVUELTA' then
              vrespuesta2 := pac_con.f_tag(vsinterf, 'identificador', 'TMENINHOST');
              if vrespuesta2 = '43' then
                vrespuesta := 'RECIBIDA';
              elsif vrespuesta <> '50' then
                --cambiamos estado y enviamos correo del intento de envio del xml al cliente
                UPDATE sri_servrentint
                  SET cestado = 4,
                      out_r = vrespuesta
                WHERE clave = v_clave;

               COMMIT;

               vnumerr := f_ride_sri(v_clave, vsinterf);
              end if;
            end if;

            --leemos respuesta
            IF vnumerr = 0
               AND perror IS NULL
               AND vrespuesta = 'RECIBIDA' THEN
               vpasexec := 19;

               UPDATE sri_servrentint
                  SET cestado = 1,
                      out_r = vrespuesta
                WHERE clave = v_clave;

               COMMIT;

               p_continuar_sri();

               select cestado into vcestado from sri_servrentint where clave = v_clave;

               if vcestado <> 2 then
               vnumerr := f_ride_sri(v_clave, vsinterf);
               end if;

            ELSIF vrespuesta IS NOT NULL THEN
               BEGIN
                  vpasexec := 20;

                  SELECT tmenin
                    INTO vmensajes
                    FROM int_mensajes
                   WHERE sinterf = vsinterf;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                                 'Error al leer de int_mensajes ' || vnumerr || '-' || SQLCODE,
                                 vparam || ' - ' || SQLERRM || ' -vsinterf:' || vsinterf);
                     RETURN 1;
               END;

               vpasexec := 21;

               UPDATE sri_servrentint
                  SET out_r = vmensajes
                WHERE clave = v_clave;

               COMMIT;
            ELSE
               vpasexec := 22;

               UPDATE sri_servrentint
                  SET out_r = perror
                WHERE clave = v_clave;

               COMMIT;
            END IF;

            IF vnumerr > 0 THEN
               p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                           'Error incontrolado ' || vnumerr || '-' || SQLCODE,
                           vparam || ' - ' || SQLERRM || ' - ' || perror);
               RETURN vnumerr;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                           'Error incontrolado ' || SQLCODE, vparam || ' - ' || SQLERRM || ' - ' || perror);
               RETURN SQLCODE;
         END;

         RETURN 0;
      ELSE
         p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                     'Error incontrolado ' || SQLCODE, vparam || ' - ' || SQLERRM);
         RETURN 1;
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', vpasexec,
                     'Error incontrolado ' || SQLCODE, vparam || ' - ' || SQLERRM);
         RETURN 1;
   END p_envio_sri;

   PROCEDURE p_reproceso_sri IS
      /***********************************************************************
                           P_CONTINUAR_SRI: Proceso que procesa los registros en la tabla sri_servrentint.
      ***********************************************************************/
      CURSOR cur_sri IS
         SELECT   *
             FROM sri_servrentint
            WHERE cestado = 0
         ORDER BY sseguro;

      variab         NUMBER := 0;
      vsinterf       NUMBER;
      vresultado     NUMBER(10);
      vresultado2    NUMBER(10);
      vnerror        NUMBER(10);
      perror         VARCHAR2(2200);
      vnumerr        NUMBER;
      psinterf       NUMBER;
      vpendientes    NUMBER := 0;
      v_sseguro      NUMBER;
      v_idpago       contab_asient_interf.idpago%TYPE;
      v_ttippag      contab_asient_interf.ttippag%TYPE;
      vlineaini      VARCHAR2(500);
      v_interficie   VARCHAR2(100);
      vrepr          NUMBER(1) := 0;
      vreprocesar    NUMBER(1) := 0;
      v_asient       NUMBER;
      vterminal      VARCHAR2(200);
      v_contar       NUMBER;
   BEGIN
      FOR v_repr IN cur_sri LOOP
         --si el estado contin¿a 0 reenviamos.
         vnumerr := p_envio_sri(pac_md_common.f_get_cxtempresa, v_repr.sseguro,
                                v_repr.nmovimi, v_repr.ctipo);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_sri.p_reproceso_sri', 2,
                     'Error incontrolado ' || SQLCODE, SQLERRM);
   END p_reproceso_sri;

   PROCEDURE p_continuar_sri IS
            /***********************************************************************
                                 P_CONTINUAR_SRI: Proceso que procesa los registros en la tabla sri_servrentint.
                                  Estados disponibles:
                                      0 -Este estado se da cuando creamos por primera vez la factura o nota de cr¿dito y cuando recibimos una recepci¿n err¿nea. Actuaci¿n: Enviar al webservice de recepci¿n.
      1- Recepci¿n ok, esperando a que llegue respuesta ok.Actuaci¿n: Preguntamos al webservice si tiene respuesta.
      2-Enviado OK. Actuaci¿n: Enviamos los documentos necesarios al asegurado.
            ***********************************************************************/
      CURSOR cur_sri IS
         SELECT   *
             FROM sri_servrentint
            WHERE cestado = 1
         ORDER BY sseguro;

      variab         NUMBER := 0;
      vsinterf       NUMBER;
      vresultado     NUMBER(10);
      vresultado2    NUMBER(10);
      vnerror        NUMBER(10);
      perror         VARCHAR2(2200);
      vnumerr        NUMBER;
      psinterf       NUMBER;
      vpendientes    NUMBER := 0;
      v_sseguro      NUMBER;
      v_idpago       contab_asient_interf.idpago%TYPE;
      v_ttippag      contab_asient_interf.ttippag%TYPE;
      vlineaini      VARCHAR2(500);
      v_interficie   VARCHAR2(100);
      vrepr          NUMBER(1) := 0;
      vreprocesar    NUMBER(1) := 0;
      v_asient       NUMBER;
      vterminal      VARCHAR2(200);
      v_contar       NUMBER;
      l_refcursor    sys_refcursor;
      vrespuesta     VARCHAR2(100);
      vnautoriza     VARCHAR2(100);
      vsfautoriza    VARCHAR2(100);
      vfautoriza     DATE;
      vmensajes      CLOB;
   BEGIN
      FOR v_repr IN cur_sri LOOP
         --si el estado contin¿a 1 volvemos a llamar.
         vsinterf := NULL;

         OPEN l_refcursor FOR
            SELECT v_repr.clave claveaccesocomprobante, SUBSTR(v_repr.clave, 24, 1) ambiente
              FROM DUAL;

         vnumerr := pac_con.f_connect_estandar(pac_md_common.f_get_cxtempresa, v_repr.sseguro,
                                               v_repr.nmovimi, vsinterf, perror,
                                               XMLTYPE(l_refcursor).getclobval, 3,
                                               'iaxcon_auth_comp', 'I051');

         UPDATE sri_servrentint
            SET sinterf_a = vsinterf
          WHERE clave = v_repr.clave;

         COMMIT;
         vrespuesta := pac_con.f_tag(vsinterf, 'estado', 'TMENINHOST');

         --leemos respuesta
         IF vnumerr = 0
            AND perror IS NULL
            AND vrespuesta = 'AUTORIZADO' THEN
            vnautoriza := pac_con.f_tag(vsinterf, 'numeroAutorizacion', 'TMENINHOST');
            vsfautoriza := pac_con.f_tag(vsinterf, 'fechaAutorizacion', 'TMENINHOST');
            vfautoriza := to_date(substr(vsfautoriza,1,10)||' '||substr(vsfautoriza,12,8),'yyyy-mm-dd hh24:mi:ss');

            BEGIN
               SELECT tmenin
                 INTO vmensajes
                 FROM int_mensajes
                WHERE sinterf = vsinterf;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_sri.p_continuar_sri', 1,
                              'Error al leer de int_mensajes ' || vnumerr || '-' || SQLCODE,
                              SQLERRM);
                  EXIT;
            END;

            UPDATE sri_servrentint
               SET cestado = 2,
                   out_a = vrespuesta || ' ' || vmensajes,
                   nautoriza = vnautoriza,
                   fautoriza = vfautoriza
             WHERE clave = v_repr.clave;

            COMMIT;

            vnumerr := f_ride_sri(v_repr.clave, 0);
            IF vnumerr <> 0 then
              p_tab_error(f_sysdate, f_user, 'pac_sri.p_continuar_sri', 1,
                              'Error al enviar correo ' || vnumerr || '-' || SQLCODE,
                              SQLERRM);
            end if;

         ELSIF vnumerr = 0
            AND perror IS NULL
            AND vrespuesta = 'NO AUTORIZADO' THEN
            BEGIN
               SELECT tmenin
                 INTO vmensajes
                 FROM int_mensajes
                WHERE sinterf = vsinterf;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_sri.p_continuar_sri', 2,
                              'Error al leer de int_mensajes ' || vnumerr || '-' || SQLCODE,
                              SQLERRM);
                  EXIT;
            END;

            --no autorizado, no se reprocesa
            UPDATE sri_servrentint
               SET cestado = 3,
                   out_a = vrespuesta || ' ' || vmensajes
             WHERE clave = v_repr.clave;

            COMMIT;
         ELSIF vrespuesta IS NOT NULL THEN
            BEGIN
               SELECT tmenin
                 INTO vmensajes
                 FROM int_mensajes
                WHERE sinterf = vsinterf;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_sri.p_continuar_sri', 3,
                              'Error al leer de int_mensajes ' || vnumerr || '-' || SQLCODE,
                              SQLERRM);
                  EXIT;
            END;

            UPDATE sri_servrentint
               SET out_a = vmensajes
             WHERE clave = v_repr.clave;

            COMMIT;
         ELSE
            UPDATE sri_servrentint
               SET out_a = perror
             WHERE clave = v_repr.clave;

            COMMIT;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_sri.p_continuar_sri', 4,
                     'Error incontrolado ' || SQLCODE, SQLERRM);
   END p_continuar_sri;

   FUNCTION f_comprobar_sri(psseguro IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vpermite       NUMBER := 0;
   BEGIN
      --comprueba si existen facturas o notas de credito pendientes de confirmar por el sri
      SELECT COUNT(1)
        INTO vpermite
        FROM sri_servrentint
       WHERE sseguro = psseguro
         AND cestado <> 2;

      IF vpermite <> 0 THEN
         vpermite := 9908986;
      END IF;

      RETURN vpermite;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sri.f_comprobar_sri', vpasexec,
                     psseguro || ' Error incontrolado ' || SQLCODE, SQLERRM);
         RETURN 0;
   END f_comprobar_sri;

   /*************************************************************************
      FUNCTION f_detalle_primas
      Funci¿n que se utilizar¿ para obtener el importe detallado de las primas.
      param in NMOVIMI   : N¿mero de movimiento
      param in P_TIPO    : 1 ¿ Importe Prima Neta hasta la renovaci¿n/vencimiento
                          2 - Importe del Primer Recibo (solo en N.P.)
                     3 - Importe Impuestos hasta la renovaci¿n/vencimiento
                     4 - Importe Hasta la renovaci¿n/vencimiento Consorcio
                     5 - Importe hasta renovaci¿n/vencimiento Recargo Fracc.
                     9 - Importe de recibo succesivo (solo en N.P.)
      param in P_TABLAS    : C¿digo de seguro
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_detalle_primas(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_tipo IN NUMBER,
      p_tablas IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 AS
      CURSOR c_garantias IS
         SELECT cgarant, iprianu, nriesgo, nmovimi, idtocom, idtotec
           FROM garanseg
          WHERE sseguro = p_sseguro
            /*           AND nmovimi = p_nmovimi;*/
            /* Los movimientos de regularizaci¿n no se sacan*/
            AND nmovimi = (SELECT MAX(g.nmovimi)
                             FROM garanseg g, movseguro m
                            WHERE g.sseguro = p_sseguro
                              AND m.sseguro = g.sseguro
                              AND m.nmovimi = g.nmovimi
                              AND m.cmovseg <> 6
                              AND g.nmovimi <= p_nmovimi);

      r_return       VARCHAR2(2000) := NULL;
      v_imp_crecfra  imprec.crecfra%TYPE;
      v_crecfra      seguros.crecfra%TYPE;
      v_cduraci      seguros.cduraci%TYPE;
      v_fvencim      seguros.fvencim%TYPE;
      v_fcaranu      seguros.fcaranu%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_fcarpro      seguros.fcarpro%TYPE;
      v_frenova      seguros.frenova%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_nanuali      seguros.nanuali%TYPE;
      v_cprorra      productos.cprorra%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      vobj           VARCHAR2(200) := 'pac_isqlfor_prb.f_detalle_primas';
      v_err          NUMBER;
      v_iprianu      NUMBER := 0;
      v_iprigar      NUMBER;
      /* imprec*/
      v_ctipcon      imprec.ctipcon%TYPE;
      v_nvalcon      imprec.nvalcon%TYPE;
      v_cfracci      imprec.cfracci%TYPE;
      v_cbonifi      imprec.cbonifi%TYPE;
      v_climite      imprec.climite%TYPE;
      v_cmonimp      NUMBER;
      v_cderreg      imprec.cderreg%TYPE;
      v_suplem       NUMBER;
      lfecini        DATE;
      lfecfin        DATE;
      /* Calculo impuestos*/
      v_cons_tot     NUMBER := 0;
      v_cons         NUMBER := 0;
      v_imp_ips      NUMBER := 0;
      v_ips_tot      NUMBER := 0;
      v_ips          NUMBER := 0;
      v_imp_clea     NUMBER := 0;
      v_clea_tot     NUMBER := 0;
      v_clea         NUMBER := 0;
      v_imp_rec      NUMBER := 0;
      v_rec_tot      NUMBER := 0;
      v_rec          NUMBER := 0;
      v_cforpag      NUMBER;
      lcmoneda       NUMBER;
      lpago          NUMBER;   /* Numero pagos s/forma pago*/
      lnumpago       NUMBER;   /* Numero pagos en meses*/
      vfracc         NUMBER;
      facnet         NUMBER;   /* Fraccion primer pago*/
      facdev         NUMBER;   /* Fraccion total*/
      lhaydecimales  NUMBER;   /* 0 = Meses enteros*/
      lpagodecimales NUMBER;   /* 0 = Nro. Pagos enteros*/
   BEGIN
      /* Se buscan los datos de la p¿liza*/
      SELECT s.fefecto, s.cduraci, s.crecfra, s.fvencim, s.fcaranu, s.fcarpro, s.cforpag,
             s.sproduc, s.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.nanuali,
             p.cprorra, s.frenova
        INTO v_fefecto, v_cduraci, v_crecfra, v_fvencim, v_fcaranu, v_fcarpro, v_cforpag,
             v_sproduc, v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_nanuali,
             v_cprorra, v_frenova
        FROM seguros s, productos p
       WHERE s.sseguro = p_sseguro
         AND s.sproduc = p.sproduc;

      /**/
      lcmoneda := f_parinstalacion_n('MONEDAINST');

      /* Se buscan la fecha inicio de la anualidad y*/
      /* la fecha fin de la primera fracci¿n de la anualidad.*/
      IF v_nanuali = 1 THEN
         lfecini := v_fefecto;
      ELSE
         lfecini := f_summeses(v_fcaranu, -12, TO_CHAR(v_fcaranu, 'dd'));   --ADD_MONTHS(v_fcaranu, -12);
      END IF;

      /**/
      IF v_cforpag = 0 THEN
         lfecfin := v_fcaranu;
      ELSE
         lfecfin := pac_canviforpag.f_calcula_fcarpro(v_fcaranu, v_cforpag, lfecini, lfecini);
      END IF;

      /**/
      /*-----------------> ini PRORRATEO  <------------------->*/
      DECLARE
         v_ini          DATE := lfecini;   /* Fecha Inicio Anualidad*/
         v_fin          DATE := lfecfin;   /* Fecha fin 1er Recibo Anualidad*/
         xcprorra       NUMBER := v_cprorra;
         xcforpag       NUMBER := v_cforpag;
         fanyoprox      DATE;
         xcmodulo       NUMBER;
         difdias        NUMBER;
         difdias2       NUMBER;
         divisor2       NUMBER;
         num_err        NUMBER;
         xpro_np_360    NUMBER;
         difdiasanu     NUMBER;
         difdiasanu2    NUMBER;
         xffinany       DATE;
      BEGIN
         fanyoprox := f_summeses(v_ini, 12, TO_CHAR(v_ini, 'dd'));   --ADD_MONTHS(v_ini, 12);

         IF xcprorra = 2 THEN   /* Mod. 360*/
            xcmodulo := 3;
         ELSE
            xcmodulo := 1;
         END IF;

         IF xcforpag <> 0 THEN
            xffinany := NVL(v_fcaranu, v_frenova);
         ELSE
            IF NVL(f_parproductos_v(v_sproduc, 'PRORR_PRIMA_UNICA'), 0) = 1
               AND v_fvencim IS NOT NULL THEN
               v_fin := v_fvencim;
            END IF;

            xffinany := v_fin;
         END IF;

         num_err := f_difdata(v_ini, v_fin, 3, 3, difdias);
         num_err := f_difdata(v_ini, v_fin, xcmodulo, 3, difdias2);
         num_err := f_difdata(v_ini, xffinany, 3, 3, difdiasanu);
         num_err := f_difdata(v_ini, xffinany, xcmodulo, 3, difdiasanu2);
         num_err := f_difdata(v_ini, fanyoprox, xcmodulo, 3, divisor2);

         IF xcprorra IN(1, 2) THEN   /* Per dies*/
            IF xcforpag <> 0
               OR NVL(f_parproductos_v(v_sproduc, 'PRORR_PRIMA_UNICA'), 0) = 1 THEN
               /* El c¿lcul del factor a la nova producci¿ si s'ha de prorratejar, es far¿ modul 360 o*/
                 /* m¿dul 365 segon un par¿metre d'instal.laci¿*/
               xpro_np_360 := f_parinstalacion_n('PRO_NP_360');

               IF NVL(xpro_np_360, 1) = 1 THEN
                  facnet := difdias / 360;
                  facdev := difdiasanu / 360;
               ELSE
                  IF MOD(difdias, 30) = 0
                     AND xcforpag <> 1 THEN
                     /* No hi ha prorrata*/
                     facnet := difdias / 360;
                     facdev := difdiasanu2 / 360;
                  ELSE
                     /* Hi ha prorrata, prorratejem m¿dul 365*/
                     facnet := difdias2 / divisor2;
                     facdev := difdiasanu2 / divisor2;
                  END IF;
               END IF;
            ELSE
               facnet := 1;
               facdev := 1;
            END IF;
         END IF;
      END;

      /* Nro de meses hasta la fecha de renovaci¿n.*/
      lnumpago := MONTHS_BETWEEN(v_fcaranu, lfecini);

      /* Si existen decimales el primer mes no es entero.*/
      SELECT TRUNC(lnumpago)
        INTO lhaydecimales
        FROM DUAL;

      lhaydecimales := lnumpago - lhaydecimales;

      SELECT TRUNC(lnumpago)
        INTO lnumpago
        FROM DUAL;

      /* En funci¿n de la forma de pago miro cuantos pagos se har¿n en la*/
      /* Anualidad.*/
      IF v_cforpag = 0 THEN
         lpago := 1;
      ELSE
         lpago := lnumpago /(12 / v_cforpag);
      END IF;

      /* Si hay decimales no hay fracciones enteras.*/
      SELECT TRUNC(lpago)
        INTO lpagodecimales
        FROM DUAL;

      lpagodecimales := lpago - lpagodecimales;

      SELECT TRUNC(lpago)
        INTO lpago
        FROM DUAL;

      /* --------------------------------- Importe Prima Neta hasta la renovaci¿n/vencimiento*/
      IF p_tipo = 1 THEN
         r_return := 0;

         FOR det IN c_garantias LOOP
            IF v_cforpag = 0 THEN
               r_return := r_return + f_round(det.iprianu * facnet, lcmoneda);
            ELSIF v_cforpag = 1 THEN
               r_return := r_return + f_round(det.iprianu * facdev, lcmoneda);
            ELSE
               /* La primera fraccion No son meses enteros o fracciones*/
                 /* segun forma de pago enteras*/
               IF ((lhaydecimales <> 0)
                   OR(lpagodecimales <> 0)) THEN
                  /* prorrateo 1era Fracci¿n*/
                  r_return := r_return + f_round(det.iprianu * facnet, lcmoneda);
               END IF;

               /* Parte Entera*/
               r_return := r_return + f_round((det.iprianu / v_cforpag), lcmoneda) * lpago;
            END IF;
         END LOOP;
      /* --------------------- Importe del Primer Recibo*/
      ELSIF p_tipo = 2 THEN
         /* Se busca directamente ya est¿ creado y s¿lo se muestra en la N.P.*/
         BEGIN
            SELECT v.itotalr
              INTO r_return
              FROM vdetrecibos v, recibos r
             WHERE v.nrecibo = r.nrecibo
               AND r.sseguro = p_sseguro
               AND r.nmovimi = p_nmovimi
               AND r.ctiprec = 0;
         EXCEPTION
            WHEN OTHERS THEN
               r_return := 0;
         END;
      /* --------------------- Importe Impuestos hasta la renovaci¿n/vencimiento*/
      ELSIF p_tipo = 3 THEN   /* S¿lo se recoge IPS 4 y la CLEA 5.*/
         FOR det IN c_garantias LOOP
/* Los impuestos 1ero se prorratea la prima y luego se calcula.*/
/* ---------------------------------------------------------------*/
/*- Calculo del 4.- IPS Contemplado si es fraccionado*/
    /* ---------------------------------------------------------------*/
            v_imp_ips := 0;
            v_ips := 0;
            v_iprianu := 0;
            /* Miro si el impuesto es fraccionado.*/
            vfracc := NVL(pac_mdobj_prod.f_importe_impuesto(p_sseguro, det.nriesgo,
                                                            det.nmovimi, 'POL', 4, v_crecfra,
                                                            det.cgarant, det.iprianu,
                                                            det.idtocom, v_ips),
                          1);

            IF v_cforpag IN(0, 1) THEN
               v_iprianu := f_round(det.iprianu * facdev, lcmoneda);
            ELSE
               /*La primera fraccion No son meses enteros o Pagos enteros*/
               IF ((lhaydecimales <> 0)
                   OR(lpagodecimales <> 0)) THEN
                  /* prorrateo 1era Fracci¿n*/
                  v_iprianu := f_round(det.iprianu * facnet, lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 4, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_ips);
                  v_imp_ips := NVL(v_imp_ips, 0) + v_ips;
                  /* Parte entera*/
                  v_iprianu := f_round((det.iprianu / v_cforpag), lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 4, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_ips);
                  v_imp_ips := NVL(v_imp_ips, 0) +(v_ips * lpago);
               ELSE
                  v_iprianu := f_round((det.iprianu / 12) * lnumpago, lcmoneda);
               END IF;
            END IF;

            /**/
            IF NVL(v_imp_ips, 0) = 0 THEN   /* No hay fracci¿n, son meses enteros*/
               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_iprianu := v_iprianu / lpago;
               END IF;

               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 4, v_crecfra, det.cgarant,
                                                       v_iprianu, det.idtocom, v_ips);

               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_ips := v_ips * lpago;
               END IF;
            ELSE   /* Hay fracci¿n.*/
               v_ips := NVL(v_imp_ips, 0);
            END IF;

            v_ips_tot := v_ips_tot + v_ips;

/* ---------------------------------------------------------------*/
/*- Calculo de la 5.- Clea Contemplado si se paga en el 1er recibo*/
/* ---------------------------------------------------------------*/
            IF v_cduraci = 3 THEN
               v_iprianu := f_round(det.iprianu * facnet, lcmoneda);
            ELSE
               IF lnumpago = 12 THEN
                  v_iprianu := det.iprianu;
               ELSE
                  IF (lhaydecimales <> 0) THEN
                     /* prorrateo 1era Fracci¿n*/
                     v_iprianu := f_round(det.iprianu * facdev, lcmoneda);
                  ELSE
                     IF v_cforpag IN(0, 1) THEN
                        v_iprianu := f_round(det.iprianu * facdev, lcmoneda);
                     ELSE
                        v_iprianu := f_round((det.iprianu / 12) * lnumpago, lcmoneda);
                     END IF;
                  END IF;
               END IF;
            END IF;

            vfracc := NVL(pac_mdobj_prod.f_importe_impuesto(p_sseguro, det.nriesgo, p_nmovimi,
                                                            'POL', 5, v_crecfra, det.cgarant,
                                                            v_iprianu, det.idtocom, v_clea),
                          1);

            IF vfracc <> 1 THEN
               v_iprianu := v_iprianu / vfracc;
            END IF;

            v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, p_nmovimi, 'POL',
                                                    5, v_crecfra, det.cgarant, v_iprianu,
                                                    det.idtocom, v_clea);
            v_clea := v_clea * vfracc;
            v_clea_tot := v_clea_tot + v_clea;
         END LOOP;

         r_return := v_ips_tot + v_clea_tot;
      /* --------------------------------- Importe Hasta la renovaci¿n/vencimiento Consorcio*/
      ELSIF p_tipo = 4 THEN
/* El consorcio se calcula al rev¿s siempre con la prima Anual y*/
/* Luego se prorratea.*/
/* ---------------------------------------------------------------*/
/*- Calculo del 2.- Consorcio. Contemplado si es 1er recibo*/
  /* ---------------------------------------------------------------*/
         FOR det IN c_garantias LOOP
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                    'POL', 2, v_crecfra, det.cgarant,
                                                    det.iprianu, det.idtocom, v_cons);

            IF v_cduraci IN(3, 6) THEN
               IF v_cduraci = 3 THEN
                  v_cons := f_round(v_cons * facnet, lcmoneda);
               ELSE
                  IF lnumpago <> 12 THEN
                     IF lhaydecimales <> 0 THEN
                        v_cons := f_round(v_cons * facdev, lcmoneda);
                     ELSE
                        IF v_cforpag IN(0, 1) THEN
                           v_cons := f_round(v_cons * facdev, lcmoneda);
                        ELSE
                           v_cons := f_round((v_cons / 12) * lnumpago, lcmoneda);
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;

            v_cons_tot := v_cons_tot + v_cons;
         END LOOP;

         r_return := v_cons_tot;
      /* ------------------- Importe hasta renovaci¿n/vencimiento Recargo Fracc.*/
      ELSIF p_tipo = 5 THEN
/* ---------------------------------------------------------------*/
/*- Calculo del 8 - Recargo. Contemplado si es fraccionado*/
  /* ---------------------------------------------------------------*/
         FOR det IN c_garantias LOOP
            /**/
            v_imp_rec := 0;
            v_rec := 0;
            v_iprianu := 0;
            /* Miro la fracci¿n.*/
            vfracc := NVL(pac_mdobj_prod.f_importe_impuesto(p_sseguro, det.nriesgo,
                                                            det.nmovimi, 'POL', 8, v_crecfra,
                                                            det.cgarant, det.iprianu,
                                                            det.idtocom, v_rec),
                          1);

            IF v_cforpag IN(0, 1) THEN
               v_iprianu := f_round(det.iprianu * facdev, lcmoneda);
            ELSE
               /*La primera fraccion No son meses enteros o Pagos enteros*/
               IF ((lhaydecimales <> 0)
                   OR(lpagodecimales <> 0)) THEN
                  /* prorrateo 1era Fracci¿n*/
                  v_iprianu := f_round(det.iprianu * facnet, lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 8, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_rec);
                  v_imp_rec := NVL(v_imp_rec, 0) + v_rec;
                  /* Parte entera*/
                  v_iprianu := f_round((det.iprianu / v_cforpag), lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 8, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_rec);
                  v_imp_rec := NVL(v_imp_rec, 0) +(v_rec * lpago);
               ELSE
                  v_iprianu := f_round((det.iprianu / 12) * lnumpago, lcmoneda);
               END IF;
            END IF;

            /**/
            IF NVL(v_imp_rec, 0) = 0 THEN   /* No hay fracci¿n, son meses enteros*/
               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_iprianu := v_iprianu / lpago;
               END IF;

               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 8, v_crecfra, det.cgarant,
                                                       v_iprianu, det.idtocom, v_rec);

               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_rec := v_rec * lpago;
               END IF;
            ELSE   /* Hay fracci¿n.*/
               v_rec := NVL(v_imp_rec, 0);
            END IF;

            v_rec_tot := v_rec_tot + v_rec;
         END LOOP;

         r_return := v_rec_tot;
      /* --------------------------------- Importe de recibo succesivo*/
      ELSIF p_tipo = 9 THEN
         /* Si la forma de pago es: (unica o anual)  o si la*/
           /* siguiente fracci¿n ya es de la siguiente anualidad no hay sucesivos.*/
         IF ((v_cforpag IN(0, 1))
             OR(p_nmovimi <> 1)
             OR(lpago <= 1)) THEN
            RETURN 0;
         END IF;

         /**/
         v_iprianu := 0;

         /**/
         FOR det IN c_garantias LOOP
            v_iprigar := 0;
            v_cons := 0;
            v_ips := 0;
            v_clea := 0;
            v_rec := 0;
            /**/
            v_iprigar := f_round(det.iprianu / v_cforpag, lcmoneda);
            v_iprianu := v_iprianu + v_iprigar;
            /* 2 Consorcio*/
            v_err := f_concepto(2, v_cempres, lfecini, v_cforpag, v_cramo, v_cmodali,
                                v_ctipseg, v_ccolect, v_cactivi, det.cgarant, v_ctipcon,
                                v_nvalcon, v_cfracci, v_cbonifi, v_imp_crecfra, v_climite,
                                v_cmonimp, v_cderreg);

            IF v_cfracci = 1 THEN
               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 2, v_imp_crecfra, det.cgarant,
                                                       v_iprigar, det.idtocom, v_cons);
               v_cons_tot := v_cons_tot + v_cons;
            END IF;

            /* 4 IPS*/
            v_err := f_concepto(4, v_cempres, lfecini, v_cforpag, v_cramo, v_cmodali,
                                v_ctipseg, v_ccolect, v_cactivi, det.cgarant, v_ctipcon,
                                v_nvalcon, v_cfracci, v_cbonifi, v_imp_crecfra, v_climite,
                                v_cmonimp, v_cderreg);

            IF v_cfracci = 1 THEN
               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 4, v_imp_crecfra, det.cgarant,
                                                       v_iprigar, det.idtocom, v_ips);
               v_ips_tot := v_ips_tot + v_ips;
            END IF;

            /* 5 CLEA*/
            v_err := f_concepto(5, v_cempres, lfecini, v_cforpag, v_cramo, v_cmodali,
                                v_ctipseg, v_ccolect, v_cactivi, det.cgarant, v_ctipcon,
                                v_nvalcon, v_cfracci, v_cbonifi, v_imp_crecfra, v_climite,
                                v_cmonimp, v_cderreg);

            IF v_cfracci = 1 THEN
               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 5, v_imp_crecfra, det.cgarant,
                                                       v_iprigar, det.idtocom, v_clea);
               v_clea_tot := v_clea_tot + v_clea;
            END IF;

            /* 8 Recargo*/
            v_err := f_concepto(8, v_cempres, lfecini, v_cforpag, v_cramo, v_cmodali,
                                v_ctipseg, v_ccolect, v_cactivi, det.cgarant, v_ctipcon,
                                v_nvalcon, v_cfracci, v_cbonifi, v_imp_crecfra, v_climite,
                                v_cmonimp, v_cderreg);

            IF v_cfracci = 1 THEN
               /* Envio el recargo de fraccionamiento de la p¿liza no de imprec.*/
               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 8, v_crecfra, det.cgarant,
                                                       v_iprigar, det.idtocom, v_rec);
               v_rec_tot := v_rec_tot + v_rec;
            END IF;
         /**/
         END LOOP;

         r_return := v_iprianu + v_cons_tot + v_ips_tot + v_clea_tot + v_rec_tot;
      --descuentos
      ELSIF p_tipo = 10 THEN
         r_return := 0;

         FOR det IN c_garantias LOOP
            IF v_cforpag = 0 THEN
               r_return := r_return
                           + f_round(ABS((det.idtocom * facnet) +(det.idtotec * facnet)),
                                     lcmoneda);
            ELSIF v_cforpag = 1 THEN
               r_return := r_return
                           + f_round(ABS((det.idtocom * facnet) +(det.idtotec * facnet)),
                                     lcmoneda);
            ELSE
               /* La primera fraccion No son meses enteros o fracciones*/
                 /* segun forma de pago enteras*/
               IF ((lhaydecimales <> 0)
                   OR(lpagodecimales <> 0)) THEN
                  /* prorrateo 1era Fracci¿n*/
                  r_return := r_return
                              + f_round(ABS((det.idtocom * facnet) +(det.idtotec * facnet)),
                                        lcmoneda);
               END IF;

               /* Parte Entera*/
               r_return := r_return
                           + f_round((ABS(det.idtocom + det.idtotec) / v_cforpag), lcmoneda)
                             * lpago;
            END IF;
         END LOOP;
      ELSIF p_tipo = 11 THEN   /* S¿lo se recoge IVA 4*/
         FOR det IN c_garantias LOOP
/* Los impuestos 1ero se prorratea la prima y luego se calcula.*/
/* ---------------------------------------------------------------*/
/*- Calculo del 4.- IPS Contemplado si es fraccionado*/
    /* ---------------------------------------------------------------*/
            v_imp_ips := 0;
            v_ips := 0;
            v_iprianu := 0;
            /* Miro si el impuesto es fraccionado.*/
            vfracc := NVL(pac_mdobj_prod.f_importe_impuesto(p_sseguro, det.nriesgo,
                                                            det.nmovimi, 'POL', 4, v_crecfra,
                                                            det.cgarant, det.iprianu,
                                                            det.idtocom, v_ips),
                          1);

            IF v_cforpag IN(0, 1) THEN
               v_iprianu := f_round(det.iprianu * facdev, lcmoneda);
            ELSE
               /*La primera fraccion No son meses enteros o Pagos enteros*/
               IF ((lhaydecimales <> 0)
                   OR(lpagodecimales <> 0)) THEN
                  /* prorrateo 1era Fracci¿n*/
                  v_iprianu := f_round(det.iprianu * facnet, lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 4, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_ips);
                  v_imp_ips := NVL(v_imp_ips, 0) + v_ips;
                  /* Parte entera*/
                  v_iprianu := f_round((det.iprianu / v_cforpag), lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 4, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_ips);
                  v_imp_ips := NVL(v_imp_ips, 0) +(v_ips * lpago);
               ELSE
                  v_iprianu := f_round((det.iprianu / 12) * lnumpago, lcmoneda);
               END IF;
            END IF;

            /**/
            IF NVL(v_imp_ips, 0) = 0 THEN   /* No hay fracci¿n, son meses enteros*/
               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_iprianu := v_iprianu / lpago;
               END IF;

               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 4, v_crecfra, det.cgarant,
                                                       v_iprianu, det.idtocom, v_ips);

               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_ips := v_ips * lpago;
               END IF;
            ELSE   /* Hay fracci¿n.*/
               v_ips := NVL(v_imp_ips, 0);
            END IF;

            v_ips_tot := v_ips_tot + v_ips;
            r_return := v_ips_tot;
         END LOOP;
      ELSIF p_tipo = 12 THEN   /* S¿lo se recoge SBS 5*/
         FOR det IN c_garantias LOOP
/* Los impuestos 1ero se prorratea la prima y luego se calcula.*/
/* ---------------------------------------------------------------*/
/*- Calculo del 5.- SBS Contemplado si es fraccionado*/
    /* ---------------------------------------------------------------*/
            v_imp_ips := 0;
            v_ips := 0;
            v_iprianu := 0;
            /* Miro si el impuesto es fraccionado.*/
            vfracc := NVL(pac_mdobj_prod.f_importe_impuesto(p_sseguro, det.nriesgo,
                                                            det.nmovimi, 'POL', 5, v_crecfra,
                                                            det.cgarant, det.iprianu,
                                                            det.idtocom, v_ips),
                          1);

            IF v_cforpag IN(0, 1) THEN
               v_iprianu := f_round(det.iprianu * facdev, lcmoneda);
            ELSE
               /*La primera fraccion No son meses enteros o Pagos enteros*/
               IF ((lhaydecimales <> 0)
                   OR(lpagodecimales <> 0)) THEN
                  /* prorrateo 1era Fracci¿n*/
                  v_iprianu := f_round(det.iprianu * facnet, lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 5, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_ips);
                  v_imp_ips := NVL(v_imp_ips, 0) + v_ips;
                  /* Parte entera*/
                  v_iprianu := f_round((det.iprianu / v_cforpag), lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 5, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_ips);
                  v_imp_ips := NVL(v_imp_ips, 0) +(v_ips * lpago);
               ELSE
                  v_iprianu := f_round((det.iprianu / 12) * lnumpago, lcmoneda);
               END IF;
            END IF;

            /**/
            IF NVL(v_imp_ips, 0) = 0 THEN   /* No hay fracci¿n, son meses enteros*/
               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_iprianu := v_iprianu / lpago;
               END IF;

               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 5, v_crecfra, det.cgarant,
                                                       v_iprianu, det.idtocom, v_ips);

               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_ips := v_ips * lpago;
               END IF;
            ELSE   /* Hay fracci¿n.*/
               v_ips := NVL(v_imp_ips, 0);
            END IF;

            v_ips_tot := v_ips_tot + v_ips;
            r_return := v_ips_tot;
         END LOOP;
      ELSIF p_tipo = 13 THEN   /* S¿lo se recoge Impuesto Campesino 6*/
         FOR det IN c_garantias LOOP
/* Los impuestos 1ero se prorratea la prima y luego se calcula.*/
/* ---------------------------------------------------------------*/
/*- Calculo del 4.- IPS Contemplado si es fraccionado*/
    /* ---------------------------------------------------------------*/
            v_imp_ips := 0;
            v_ips := 0;
            v_iprianu := 0;
            /* Miro si el impuesto es fraccionado.*/
            vfracc := NVL(pac_mdobj_prod.f_importe_impuesto(p_sseguro, det.nriesgo,
                                                            det.nmovimi, 'POL', 6, v_crecfra,
                                                            det.cgarant, det.iprianu,
                                                            det.idtocom, v_ips),
                          1);

            IF v_cforpag IN(0, 1) THEN
               v_iprianu := f_round(det.iprianu * facdev, lcmoneda);
            ELSE
               /*La primera fraccion No son meses enteros o Pagos enteros*/
               IF ((lhaydecimales <> 0)
                   OR(lpagodecimales <> 0)) THEN
                  /* prorrateo 1era Fracci¿n*/
                  v_iprianu := f_round(det.iprianu * facnet, lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 6, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_ips);
                  v_imp_ips := NVL(v_imp_ips, 0) + v_ips;
                  /* Parte entera*/
                  v_iprianu := f_round((det.iprianu / v_cforpag), lcmoneda);
                  v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                          'POL', 6, v_crecfra, det.cgarant,
                                                          v_iprianu, det.idtocom, v_ips);
                  v_imp_ips := NVL(v_imp_ips, 0) +(v_ips * lpago);
               ELSE
                  v_iprianu := f_round((det.iprianu / 12) * lnumpago, lcmoneda);
               END IF;
            END IF;

            /**/
            IF NVL(v_imp_ips, 0) = 0 THEN   /* No hay fracci¿n, son meses enteros*/
               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_iprianu := v_iprianu / lpago;
               END IF;

               v_err := pac_tarifas.f_calcula_concepto(p_sseguro, det.nriesgo, det.nmovimi,
                                                       'POL', 6, v_crecfra, det.cgarant,
                                                       v_iprianu, det.idtocom, v_ips);

               IF vfracc <> 1
                  AND lpago > 1 THEN
                  v_ips := v_ips * lpago;
               END IF;
            ELSE   /* Hay fracci¿n.*/
               v_ips := NVL(v_imp_ips, 0);
            END IF;

            v_ips_tot := v_ips_tot + v_ips;
            r_return := v_ips_tot;
         END LOOP;
      END IF;

      RETURN r_return;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_detalle_primas;

   FUNCTION f_ride_sri(pclave IN VARCHAR2, psinterf IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vpermite       NUMBER := 0;
      pncarpeta      VARCHAR2(500);
      mensajes       t_iax_mensajes := t_iax_mensajes();
      vobjectname    VARCHAR2(500) := 'PAC_SRI.f_ride_sri';
      vnumerr        NUMBER(8) := 0;
      vmap           cfg_lanzar_informes.cmap%TYPE;
      vemp           cfg_lanzar_informes.cempres%TYPE;
      vidi           det_lanzar_informes.cidioma%TYPE;
      onomfichero    VARCHAR2(1000);
      ofichero       VARCHAR2(1000);
      vclob clob;
      vtinfo         t_iax_info;
      vinfo          ob_iax_info;
      b_error        BOOLEAN;

      ptfilename VARCHAR2(500) := 'clave.xml';
 vterror    VARCHAR2 (1000);
 viddoc     NUMBER (8)      := 0;
 v_dirpdfgdx VARCHAR(50) := NULL;



      CURSOR c_correos_asegurado IS
         SELECT p.tvalcon, s.out_a, s.sseguro, s.nmovimi
           FROM sri_servrentint s, asegurados a, per_contactos p
          WHERE s.clave = pclave
            AND s.sseguro = a.sseguro
            AND a.sperson = p.sperson(+)
            AND p.ctipcon(+) = 3;
   BEGIN
      --genera el documento RIDE
      vemp := pac_md_common.f_get_cxtempresa;
      vidi := pac_md_common.f_get_cxtidioma;
      vtinfo := t_iax_info();
      vinfo := ob_iax_info();
      b_error := FALSE;
      vmap := 'AMA0008';

      IF vmap IS NOT NULL THEN
         vtinfo.DELETE;
         vtinfo.EXTEND;
         vinfo.nombre_columna := 'CLAVE';
         vinfo.valor_columna := pclave;
         vinfo.tipo_columna := '1';
         vtinfo(vtinfo.LAST) := vinfo;
         -- proceso impresion
            --genera el documento RIDE
        -- vnumerr := pac_md_informes.f_ejecuta_informe(vmap, vemp, 'PDF', vtinfo, vidi, 1,
        --                                              NULL, onomfichero, ofichero, mensajes);

         IF vnumerr != 0 THEN
            b_error := TRUE;
         ELSE
            -- Enviar el correo al asegurado de la p¿liza
            FOR v_cursor IN c_correos_asegurado LOOP
               BEGIN
                  --p_enviar_correo(v_from, v_to, v_from, v_to2, v_subject, v_texto);

                  IF psinterf <> 0 then
                    select xml_respuesta into vclob
                    from int_datos_xml where sinterf = psinterf;

                    ptfilename := pclave || '_envio.xml';

                  else
                    vclob := v_cursor.out_a;
                    ptfilename := pclave || '_autoriza.xml';
                  end if;


 vnumerr := f_xml_sri(vclob,ptfilename,pac_md_common.f_get_parinstalacion_t('GEDOX_DIR'));

 vnumerr := pac_md_impresion.f_set_documgedox(v_cursor.sseguro,
     v_cursor.nmovimi,
     f_user,
     ptfilename,
     'XML ENVIO SRI',
     1,
     viddoc,
     mensajes);

if v_cursor.tvalcon is not null then

                  --Inicio Bug AMA-469 - 19/07/2016 - AMC
                  IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'ENVIO_EMAIL'),0) = 1 then
                  vnumerr :=
                     pac_md_informes.f_enviar_mail
                                     (NULL, v_cursor.tvalcon,
                                      NULL,
                                      NULL, 'CLAVE: ' || pclave, null, NULL, NULL, NULL,
                                      pac_md_common.f_get_parinstalacion_t('MAIL_FROM'), pac_md_common.f_get_parinstalacion_t('GEDOX_DIR'),
                                      ptfilename);
                  end if;
                  --Fin Bug AMA-469 - 19/07/2016 - AMC
end if;
               EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'pac_sri.f_ride_sri', 2,
                                 'Error al enviar correo a :, ' || v_cursor.tvalcon || '-' || SQLCODE,
                                 ptfilename || ' -sinterf: ' || psinterf );
                    -- vnumerr := SQLCODE || ' ' || SQLERRM || CHR(10) || 'pscorreo=' || 1
                    --            || ' to=' || v_cursor.tvalcon || ' ' || pclave;
                      --Bug 27520/147846 - 28/06/2013 - AMC
                     -- p_log_correo(f_sysdate, 'jdelrio@csi-ti.com', f_user, 'asunto', vnumerr, NULL, NULL);
                      --Fi Bug 27520/147846 - 28/06/2013 - AMC
                     b_error := TRUE;
               END;
            END LOOP;
         END IF;
      END IF;

      IF b_error THEN
         -- Documento incorrecto.
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902749);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, pclave);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, pclave);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, pclave,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_ride_sri;

   FUNCTION f_xml_sri (pl_clob IN CLOB, ptfilename in VARCHAR2, pdirpdfgdx IN VARCHAR2)
   RETURN NUMBER
   IS

  l_file    UTL_FILE.FILE_TYPE;
  --l_clob    CLOB;
  l_buffer  VARCHAR2(32767);
  l_amount  BINARY_INTEGER := 32767;
  l_pos     INTEGER := 1;
  --ptfilename VARCHAR2(100) :='archivo5.xml';
  vterror    VARCHAR2 (1000);
 viddoc     NUMBER (8)      := 0;
 vnumerr number;
 --v_dirpdfgdx VARCHAR(50) := 'GEDOXTEMPORAL';

      vfarchiv      date; --CONF 236 JAAB
      vfelimin      date; --CONF 236 JAAB
      vfcaduci      date; --CONF 236 JAAB

BEGIN
  -- Get LOB locator
  /*SELECT out_a
  INTO   l_clob
  FROM   SRI_SERVRENTINT
  WHERE  clave = '0306201601179255579500110010010000000371234567816';*/

  l_file := UTL_FILE.fopen(pdirpdfgdx,ptfilename, 'w', 32767);

  LOOP
    DBMS_LOB.read (pl_clob, l_amount, l_pos, l_buffer);
    UTL_FILE.put(l_file, l_buffer);
    l_pos := l_pos + l_amount;
  END LOOP;


  RETURN 0;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Expected end.
    UTL_FILE.fclose(l_file);

        --INI JAAB CONF-236 22/08/2016
        vfarchiv := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(1);
        vfcaduci := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(2);
        vfelimin := PAC_MD_GEDOX.F_CALCULA_FECHA_AEC(3);
        --FIN JAAB CONF 236 22/08/2016

    --pac_axisgedox.grabacabecera (f_user, ptfilename, pdirpdfgdx, 1, 1, 2, vterror, viddoc); -- JAAB CONF 236
    pac_axisgedox.grabacabecera (f_user, ptfilename, pdirpdfgdx, 1, 1, 2, vterror, viddoc, vfarchiv, vfelimin, vfcaduci);

IF vterror IS NOT NULL OR NVL (viddoc, 0) = 0
     THEN
       p_tab_error(f_sysdate, f_user, 'pac_sri.f_xml_sri', 1,
                                 'Error al grabar en gedox el xml iddoc:, ' || viddoc || '-' || SQLCODE,
                                 ptfilename || ' - ' || vterror );
         RETURN 1;
     END IF;
  pac_axisgedox.actualiza_gedoxdb (ptfilename, viddoc, vterror, Pdirpdfgdx);


  RETURN 0;

  WHEN OTHERS THEN
    UTL_FILE.fclose(l_file);
    p_tab_error(f_sysdate, f_user, 'pac_sri.p_envio_sri', 2,
                                 'Error al grabar en gedox el xml iddoc:, ' || viddoc || '-' || SQLCODE,
                                 ptfilename || ' - ' || vterror );
  RETURN 1;
END f_xml_sri;


END pac_sri;

/

  GRANT EXECUTE ON "AXIS"."PAC_SRI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SRI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SRI" TO "PROGRAMADORESCSI";
