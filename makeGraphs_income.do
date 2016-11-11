
clear
tempfile tmp

local x FL
insheet using output/`x'.csv, comma clear names
keep if poll_type == "Income"
merge m:1 state demographic using ACSData/income_pop, keep(match)
destring percentage-other3, replace force ignore("%")
duplicates drop
drop _merge
*drop other2 other3
save `tmp', replace
local files : dir "output" files "*.csv"
foreach x in `files' {
    if "`x'" != "NH.csv" & "`x'" != "TX.csv" & "`x'" != "US.csv" & "`x'" != "UT.csv" {
        disp "`x'"
    insheet using output/`x', comma clear names
    keep if poll_type == "Income"
    merge m:1 state demographic using ACSData/income_pop, keep(match)
    destring percentage-other3, replace force ignore("%")
    *drop other2 other3
    bys demographic (other1): keep if _n == 1
    duplicates drop
    drop _merge
    append using `tmp', force
    save `tmp', replace
}
}


destring percentage-other3, replace force ignore("%")
merge m:1 state using ACSData/turnout, keep(match)
drop _merge

duplicates drop

merge m:1 state using ACSData/state_pop, keep(match)
drop _merge

egen tot = total(pop ), by(state)

gen scale = state_pop/tot



gen num = sample_size * (percentage/100)
gen perc = sample_size / turnout
gen votes = num / perc

gen missing = pop*scale - votes
gen clinton_votes = sample_size * (percentage/100)* (clinton/100)  / perc
gen trump_votes = sample_size * (percentage/100)* (trump/100)  / perc
gen johnson_votes = sample_size * (percentage/100)* (other1/100)  / perc
gen stein_votes = sample_size * (percentage/100)* (other2/100)  / perc
gen other_votes = sample_size * (percentage/100)* (other3/100)  / perc

foreach x of varlist  clinton_votes trump_votes johnson_votes stein_votes other_votes missing {
    gen `x'_m = `x' / 1000000
}


graph bar (sum) clinton_votes_m trump_votes_m  missing_m  , over(demographic )  bar(1, color(dblue)) bar(2, color( dred)) bar(3, color( gray)) legend(label(1 "Clinton") label(2 "Trump") label(3 "Did Not Vote")  rows(2)) ytitle("Millions of Votes") note("@paulgp") title("Swing States") note("Excluding NH")
/*
graph bar (sum) clinton_votes_m trump_votes_m johnson_votes_m stein_votes_m missing_m if state != "US"  , over(demographic )  bar(1, color(dblue)) bar(2, color( dred)) bar(3, color( green)) bar(4, color( yellow)) bar(5, color( gray)) legend(label(1 "Clinton") label(2 "Trump") label(3 "Johnson") label(4 "Stein")  label(5 "Did Not Vote")  rows(2)) ytitle("Millions of Votes") note("@paulgp") title("Swing States")

graph export "Graphs/swing_states.png", replace
graph bar (sum) clinton_votes_m trump_votes_m missing_m  if state == "US"  ,  over(demographic )  bar(1, color(dblue)) bar(2, color( dred)) bar(3, color( gray)) bar(4, color( yellow)) bar(5, color( gray)) legend(label(1 "Clinton") label(2 "Trump")   label(3 "Did Not Vote")  rows(2)) ytitle("Millions of Votes") note("@paulgp") title("National Votes")
graph export "Graphs/national.png", replace

preserve
collapse (sum) pop clinton_votes trump_votes johnson_votes stein_votes other_votes missing if state != "US" , by(demographic)

foreach x of varlist  clinton_votes trump_votes johnson_votes stein_votes other_votes missing {
    gen `x'_share = `x' / pop
}

graph bar clinton_votes_share trump_votes_share johnson_votes_share stein_votes_share missing_share  , over(demographic )  bar(1, color(dblue)) bar(2, color( dred)) bar(3, color( green)) bar(4, color( yellow)) bar(5, color( gray)) legend(label(1 "Clinton") label(2 "Trump") label(3 "Johnson") label(4 "Stein")  label(5 "Did Not Vote")  rows(2)) ytitle("Vote Share") note("@paulgp") title("Swing States") 
graph export "Graphs/swing_states_share.png", replace


restore
foreach x of varlist  clinton_votes trump_votes johnson_votes stein_votes other_votes missing {
    gen `x'_share = `x' / pop
}


graph bar clinton_votes_share trump_votes_share missing_share  if state == "US", over(demographic ) bar(1, color(dblue)) bar(2, color( dred)) bar(3, color( gray)) bar(4, color( yellow)) bar(5, color( gray)) legend(label(1 "Clinton") label(2 "Trump")   label(3 "Did Not Vote")  rows(2)) ytitle("Vote Share") note("@paulgp") title("National") 


graph export "Graphs/national_share.png", replace

