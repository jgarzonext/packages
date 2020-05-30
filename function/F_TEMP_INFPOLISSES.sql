--------------------------------------------------------
--  DDL for Function F_TEMP_INFPOLISSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TEMP_INFPOLISSES" 
 (proces NUMBER,
 empres seguros.cempres%type,
 pcramo seguros.cramo%type,
 pcmodali seguros.cmodali%type,
 pctipseg  seguros.ctipseg%type,
 pccolect  seguros.ccolect%type,
 pcagente number,
 pcsubage seguredcom.CAGESEG%type
 ) return number authid current_user is
cursor recorrer is
      select s.sseguro,s.cempres,s.npoliza,s.ncertif,s.cramo,s.cmodali,s.ctipseg,
	     s.ccolect,s.fefecto,s.femisio,s.fcaranu,s.cduraci,s.nduraci,
	     s.cforpag,s.fvencim,s.cagente,s.cactivi,s.cobjase,s.ctipcoa,
	     r.nriesgo,r.nasegur,r.tnatrie,r.sperson,
	     g.cgarant,
-- Recalculem la prima anual tenint en compte la forma de pagament 0 que no s'ha de
-- comptabilitzar
--	     g.iprianu,
	     DECODE(s.nanuali,1, g.iprianu, DECODE(s.cforpag,0,0,g.iprianu)) iprianu,
	     g.icapital,g.ctarifa,g.crevali,g.prevali,
	     g.pdtocom,g.iextrap,g.precarg,g.itarrea
      from   garanseg g, riesgos r,
	     seguros s
      where  s.cempres = empres
	and  (s.cramo  = pcramo or pcramo is null)
	and  s.cmodali = NVL(pcmodali,s.cmodali)
	and  s.ctipseg = NVL(pctipseg,s.ctipseg)
	and  s.ccolect = NVL(pccolect,s.ccolect)
	and  s.csituac in (0,5)
	-- Nomes volem les polisses actives a la data d'avui
	and  s.fefecto <= f_sysdate
	and  (s.fvencim > f_sysdate or s.fvencim is null)
	and  s.sseguro = r.sseguro
	and  s.sseguro = g.sseguro
	and  r.nriesgo = g.nriesgo
		and  g.ffinefe is null
		and  r.fanulac is null
-- Canvi en la forma d'obtenir les dades
--        and  g.nmovimi in (select max(m.nmovimi)
--                           from movseguro m
--                           where m.sseguro = s.sseguro
--                           and   m.cmovseg <> 6)
  order by s.npoliza,s.ncertif,r.nriesgo,g.cgarant;
 aux NUMBER;
 cont NUMBER;
begin
	aux := 0;
	for i in recorrer loop
		IF nvl(pcsubage, 0) = 0 THEN -- Sin subagentes
			IF pcagente IS NOT NULL THEN -- Si hi ha agent, mirem si el contracte es seu
				SELECT COUNT(*)
				INTO cont
				FROM seguredcom se
				WHERE se.SSEGURO = i.sseguro
					and se.CEMPRES = i.cempres
					and se.CAGESEG = pcagente;
			ELSE           -- Si no hi ha agent que restringeixi, ho agafem
				cont := 1;
			END IF;
		ELSIF nvl(pcsubage, 0) = 1 THEN -- Con subagentes
			IF pcagente IS NOT NULL THEN -- Si hi ha agent, mirem si el contracte es seu
				SELECT COUNT(*)
				INTO cont
				FROM seguredcom se
				WHERE se.SSEGURO = i.sseguro
					and se.CEMPRES = i.cempres
					and trunc(se.FMOVINI) <= trunc(sysdate)
					and trunc(nvl(se.FMOVFIN, sysdate + 1)) > trunc(sysdate)
					and ( C00 = pcagente or
					C01  = pcagente or
					C02  = pcagente or
					C03  = pcagente or
					C04  = pcagente or
					C05  = pcagente or
					C06  = pcagente or
					C07  = pcagente or
					C08  = pcagente or
					C09  = pcagente or
					C10  = pcagente or
					C11  = pcagente or
					C12  = pcagente);
			ELSE           -- Si no hi ha agent que restringeixi, ho agafem
				cont := 1;
			END IF;
		ELSE -- Si no tenim informat l'agent, gravem
			cont := 1;
		END IF;
		IF cont > 0 THEN -- Si hem de insertar les dades...
			insert into TEMP_INFPOLISSES
			values (proces, i.sseguro,i.npoliza,i.ncertif,i.cramo,i.cmodali,i.ctipseg,
				i.ccolect,i.fefecto,i.femisio,i.fcaranu,i.cduraci,i.nduraci,
				i.cforpag,i.fvencim,i.cagente,i.cactivi,i.cobjase,i.ctipcoa,
				i.nriesgo,i.nasegur,i.tnatrie,i.sperson,
				i.cgarant,
				i.iprianu * nvl(i.nasegur, 1), -- La prima s'ha de multiplicar pel numero d'asegurats
				i.icapital,i.ctarifa,i.crevali,i.prevali,
				i.pdtocom,i.iextrap,i.precarg,i.itarrea);
			cont := 0;
			aux := aux + 1;
		END IF;
		if aux = 100 then
			commit;
			aux := 0;
		end if;
 	end loop;
 commit;
 return (0);
exception
	when others then
		delete TEMP_INFPOLISSES where cproces = proces;
		commit;
		return (1);
end;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TEMP_INFPOLISSES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TEMP_INFPOLISSES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TEMP_INFPOLISSES" TO "PROGRAMADORESCSI";
