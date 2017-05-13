create table temp_relations as
select 	cb_relationships.id,
		cb_relationships.relationship_id, 
        cb_relationships.person_object_id, 
        cb_relationships.relationship_object_id, 
        cb_relationships.start_at, 
        cb_relationships.end_at, 
        cb_relationships.is_past, 
        cb_relationships.sequence, 
        cb_relationships.title
from cb_relationships
-- fund side
where 	(relationship_object_id like "f:%" and lower(cb_relationships.title) like "%partner%") or 
		(relationship_object_id like "f:%" and lower(cb_relationships.title) like "%managing director%") or 
        (relationship_object_id like "f:%" and lower(cb_relationships.title) like "%founder%") or 
        (relationship_object_id like "f:%" and lower(cb_relationships.title) like "%principal%") or 
        (relationship_object_id like "f:%" and lower(cb_relationships.title) like "%ceo%") or 
        (relationship_object_id like "f:%" and lower(cb_relationships.title) like "%chief executive%") or 
        (relationship_object_id like "f:%" and lower(cb_relationships.title) like "%chairman%") or 
        (relationship_object_id like "f:%" and lower(cb_relationships.title) like "%president%") or 
-- startup side
        (relationship_object_id like "c:%" and lower(cb_relationships.title) like "%founder%") or 
        (relationship_object_id like "c:%" and lower(cb_relationships.title) like "%chief executive%") or 
        (relationship_object_id like "c:%" and lower(cb_relationships.title) like "%ceo%") or 
        (relationship_object_id like "c:%" and lower(cb_relationships.title) like "%president%");
        


-- startup people education data. --
create table crunchbase.abc_startup_persons as
select 	cb_persons.id as person_id, 
		cb_persons.normalized_name as person_name, 
        cb_companies.id as startup_id, 
		cb_companies.normalized_name as startup_name, 
		lower(temp_relations.title) as job_title,
        temp_relations.relationship_object_id,
		cb_degrees.degree_type,
		cb_degrees.subject as degree_subject,
		cb_degrees.institution as degree_institution,
		cb_degrees.graduated_at as degree_graduated_at
from	temp_relations
inner join	cb_companies on cb_companies.id = temp_relations.relationship_object_id
inner join	cb_persons on cb_persons.id = temp_relations.person_object_id
left join	cb_degrees on cb_degrees.object_id = temp_relations.person_object_id
where 	temp_relations.relationship_object_id like "c:%";
	
-- finorg people education data.
create table crunchbase.abc_finorg_persons as
select 	cb_persons.id as person_id, 
		cb_persons.normalized_name as person_name, 
        cb_finorgs.id as finorg_id, 
		cb_finorgs.normalized_name as finorg_name, 
		lower(temp_relations.title) as job_title,
		cb_degrees.degree_type,
		cb_degrees.subject as degree_subject,
		cb_degrees.institution as degree_institution,
		cb_degrees.graduated_at as degree_graduated_at
from	temp_relations
inner join	cb_finorgs on cb_finorgs.id = temp_relations.relationship_object_id
inner join	cb_persons on cb_persons.id = temp_relations.person_object_id
left join	cb_degrees on cb_degrees.object_id = temp_relations.person_object_id
where 	temp_relations.relationship_object_id like "f:%";
	
-- startup data.
create table crunchbase.abc_startup_data as
select 	cb_companies.id as startup_id,
		cb_companies.name as startup_name_raw,
		cb_companies.normalized_name as startup_name,
		cb_companies.status as startup_status,
		cb_companies.founded_at as startup_founding_date,
		cb_companies.closed_at as startup_closing_date,
		cb_companies.overview as startup_description,
		cb_companies.country_code as startup_country,
		cb_companies.state_code as startup_state,
		cb_companies.city as startup_city,
		cb_offices.zip_code as startup_zip_code,
		-- acquisition data.
		cb_acquisitions.term_code as startup_acq_term,
		cb_acquisitions.price_amount as startup_acq_price,
		cb_acquisitions.price_currency_code as startup_acq_price_currency,
		cb_acquisitions.acquired_at as startup_acq_date,
		-- ipo data.
		cb_ipos.valuation_amount as startup_ipo_value,
		cb_ipos.valuation_currency_code as startup_ipo_value_currency,
		cb_ipos.raised_amount as startup_ipo_raised,
		cb_ipos.raised_currency_code as startup_ipo_raised_currency,
		cb_ipos.public_at as startup_ipo_date
from 	cb_companies
inner join 	cb_offices on cb_companies.id = cb_offices.object_id
					  and cb_companies.country_code = cb_offices.country_code
					  and cb_companies.state_code = cb_offices.state_code
					  and cb_companies.city = cb_offices.city
left join 	cb_acquisitions on cb_companies.id = cb_acquisitions.acquired_object_id
left join 	cb_ipos on cb_companies.id = cb_ipos.object_id;

-- startup id and description only - for matching with sdc.
create table crunchbase.abc_startup_sdc as
select 	abc_startup_data.startup_id,
		abc_startup_data.startup_description
from crunchbase.abc_startup_data;
	
-- finorg data.
create table crunchbase.abc_finorg_data as
select 	cb_finorgs.id as finorg_id,
		cb_finorgs.name as finorg_name_raw,
		cb_finorgs.normalized_name as finorg_name,
		cb_finorgs.status as finorg_status,
		cb_finorgs.founded_at as finorg_founding_date,
		cb_finorgs.closed_at as finorg_closing_date,
		cb_finorgs.overview as finorg_description,
		cb_finorgs.country_code as finorg_country,
		cb_finorgs.state_code as finorg_state,
		cb_finorgs.city as finorg_city,
		cb_offices.zip_code as finorg_zip_code,
		-- extra finorg stuff.
		cb_finorgs.investment_rounds as finorg_investment_rounds,
		cb_finorgs.invested_companies as finorg_invested_companies
from 	cb_finorgs
inner join 	cb_offices on cb_finorgs.id = cb_offices.object_id
					  and cb_finorgs.country_code = cb_offices.country_code
					  and cb_finorgs.state_code = cb_offices.state_code
					  and cb_finorgs.city = cb_offices.city;
	
	
-- abc_funding_rounds-- actual funding rounds.
create table crunchbase.abc_funding_rounds as
select 	cb_funding_rounds.object_id as startup_id,
		cb_funding_rounds.funded_at as startup_funding_date,
		cb_funding_rounds.raised_amount_usd as startup_raised_amount_usd,
		cb_funding_rounds.pre_money_valuation_usd as startup_pre_value_usd,
		cb_funding_rounds.post_money_valuation_usd as startup_post_value_usd,
		cb_funding_rounds.is_last_round as startup_round_one,
		cb_funding_rounds.funding_round_id as startup_funding_round_id,
		cb_investments.investor_object_id as finorg_id
from 	cb_funding_rounds
inner join 	cb_investments on cb_funding_rounds.funding_round_id = cb_investments.funding_round_id
where cb_funding_rounds.is_last_round = 1 and cb_investments.investor_object_id like "f%";
	
	
/*
create table crunchbase.cb_finorgs_companies as
select cb_companies.id as company_id, 
       cb_companies.city as company_city,
       cb_companies.state_code as company_state,
       cb_companies.region as company_region,
       cb_companies.country_code as company_country,
       cb_companies.investment_rounds as company_inv_rounds,
       cb_companies.invested_companies as company_inv_coy,
       cb_companies.funding_total_usd as company_total_fund,
       cb_companies.funding_rounds as company_total_fund_round,
       cb_companies.relationships as company_relationships,
	   cb_finorgs.id as finorgs_id, 
       cb_finorgs.country_code as finorg_country,
       cb_finorgs.state_code as finorg_state,
       cb_finorgs.city as finorg_city,
       cb_finorgs.region as finorg_region,
       cb_finorgs.investment_rounds as finorg_inv_rounds,
       cb_finorgs.invested_companies as finorg_inv_coy,
       cb_finorgs.relationships as finorg_relationships,
       cb_investments.id as investment_id,
       cb_investments.funding_round_id,
       cb_investments.funded_object_id,
       cb_investments.investor_object_id,
	   cb_offices.zip_code
	from cb_investments
    inner join cb_finorgs on cb_investments.investor_object_id = cb_finorgs.id
    inner join cb_companies on cb_investments.funded_object_id = cb_companies.id
	inner join cb_offices on cb_companies.state_code = cb_offices.state_code and cb_companies.city = cb_offices.city and cb_companies.id = cb_offices.object_id
    
create table crunchbase.cb_funding_data as
select cb_funding_rounds.*, cb_investments.funded_object_id, cb_investments.investor_object_id
	from cb_funding_rounds 
	inner join cb_investments on cb_funding_rounds.funding_round_id = cb_investments.funding_round_id
*/



 
