#---
# Excerpted from "Rails Recipes",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/rr2 for more book information.
#---
require 'csv'

class GlobalizeMigration < ActiveRecord::Migration

  def self.up
    create_table :globalize_countries, :force => true do |t|
      t.column :code,               :string, :limit => 2
      t.column :english_name,       :string
      t.column :date_format,        :string
      t.column :currency_format,    :string
      t.column :currency_code,      :string, :limit => 3
      t.column :thousands_sep,      :string, :limit => 2
      t.column :decimal_sep,        :string, :limit => 2
      t.column :currency_decimal_sep,        :string, :limit => 2
      t.column :number_grouping_scheme,      :string
    end
    add_index :globalize_countries, :code

    create_table :globalize_translations, :force => true do |t|
      t.column :type,           :string
      t.column :tr_key,         :string
      t.column :table_name,     :string
      t.column :item_id,        :integer
      t.column :facet,          :string
      t.column :language_id,    :integer
      t.column :pluralization_index, :integer
      t.column :text,           :text
    end

    add_index :globalize_translations, [ :tr_key, :language_id ]
    add_index :globalize_translations, [ :table_name, :item_id, :language_id ]

    create_table :globalize_languages, :force => true do |t|
      t.column :iso_639_1, :string, :limit => 2
      t.column :iso_639_2, :string, :limit => 3
      t.column :iso_639_3, :string, :limit => 3
      t.column :rfc_3066,  :string
      t.column :english_name, :string
      t.column :english_name_locale, :string
      t.column :english_name_modifier, :string
      t.column :native_name, :string
      t.column :native_name_locale, :string
      t.column :native_name_modifier, :string
      t.column :macro_language, :boolean
      t.column :direction, :string
      t.column :pluralization, :string
      t.column :scope, :string, :limit => 1
    end

    add_index :globalize_languages, :iso_639_1
    add_index :globalize_languages, :iso_639_2  
    add_index :globalize_languages, :iso_639_3  
    add_index :globalize_languages, :rfc_3066  

    # add in defaults
    load_from_csv("globalize_countries", country_data)
    load_from_csv("globalize_languages", language_data)
    load_from_csv("globalize_translations", translation_data)
  end

  def self.down
    drop_table :globalize_countries
    drop_table :globalize_translations
    drop_table :globalize_languages    
  end
  
  def self.load_from_csv(table_name, data)
    column_clause = nil
    is_header = false
    cnx = ActiveRecord::Base.connection
    ActiveRecord::Base.silence do
      reader = CSV::Reader.create(data) 
      
      columns = reader.shift.map {|column_name| cnx.quote_column_name(column_name) }
      column_clause = columns.join(', ')

      reader.each do |row|
        next if row.first.nil? # skip blank lines
        raise "No table name defined" if !table_name
        raise "No header defined" if !column_clause
        values_clause = row.map {|v| cnx.quote(v).gsub('\\n', "\n").gsub('\\r', "\r") }.join(', ')
        sql = "INSERT INTO #{table_name} (#{column_clause}) VALUES (#{values_clause})"
        cnx.insert(sql) 
      end
    end
  end

  def self.country_data
    <<'END_OF_DATA'
"id","code","english_name","date_format","currency_format","currency_code","thousands_sep","decimal_sep","currency_decimal_sep","number_grouping_scheme"
1,"AD","Andorra",,,"EUR",,,,"western"
2,"AE","United Arab Emirates",,,"AED",",",".",".","western"
3,"AF","Afghanistan",,,"AFA",,,,"western"
4,"AG","Antigua and Barbuda",,,"XCD",,,,"western"
5,"AI","Anguilla",,,"XCD",,,,"western"
6,"AL","Albania",,,"ALL",".",",",",","western"
7,"AM","Armenia",,,"AMD",,,,"western"
8,"AN","Netherlands Antilles",,,"ANG",,,,"western"
9,"AO","Angola",,,"AON",,,,"western"
10,"AQ","Antarctica",,,"NOK",,,,"western"
11,"AR","Argentina",,,"ARA",".",",",",","western"
12,"AS","American Samoa",,,"USD",,,,"western"
13,"AT","Austria",,"€ %n","EUR",,",",",","western"
14,"AU","Australia",,,"AUD",",",".",".","western"
15,"AW","Aruba",,,"AWG",,,,"western"
16,"AZ","Azerbaijan",,,"AZM",,".",".","western"
17,"BA","Bosnia and Herzegovina",,,"BAM",,",",",","western"
18,"BB","Barbados",,,"BBD",,,,"western"
19,"BD","Bangladesh",,,"BDT",",",".",".","western"
20,"BE","Belgium",,"%n €","EUR",".",",",",","western"
21,"BF","Burkina Faso",,,"XAF",,,,"western"
22,"BG","Bulgaria",,,"BGL"," ",",",",","western"
23,"BH","Bahrain",,,"BHD",",",".",".","western"
24,"BI","Burundi",,,"BIF",,,,"western"
25,"BJ","Benin",,,"XAF",,,,"western"
26,"BM","Bermuda",,,"BMD",,,,"western"
27,"BN","Brunei Darussalam",,,"BND",,,,"western"
28,"BO","Bolivia",,,"BOB",".",",",",","western"
29,"BR","Brazil",,"R$%n","BRR",".",",",",","western"
30,"BS","Bahamas",,,"BSD",,,,"western"
31,"BT","Bhutan",,,"BTN",,,,"western"
32,"BV","Bouvet Island",,,"NOK",,,,"western"
33,"BW","Botswana",,,"BWP",",",".",".","western"
34,"BY","Belarus",,,"BYR",,".",".","western"
35,"BZ","Belize",,,"BZD",,,,"western"
36,"CA","Canada",,,"CAD",",",".",".","western"
37,"CC","Cocos  Islands",,,"AUD",,,,"western"
38,"CD","Congo",,,,,,,"western"
39,"CF","Central African Republic",,,"XAF",,,,"western"
40,"CG","Congo",,,"XAF",,,,"western"
41,"CH","Switzerland",,"SFr. %n","CHF","'",",",".","western"
42,"CI","Cote D'Ivoire",,,"XAF",,,,"western"
43,"CK","Cook Islands",,,"NZD",,,,"western"
44,"CL","Chile",,,"CLF",".",",",",","western"
45,"CM","Cameroon",,,"XAF",,,,"western"
46,"CN","China",,"Y%n","CNY",",",".",".","western"
47,"CO","Colombia",,,"COP",".",",",",","western"
48,"CR","Costa Rica",,,"CRC",",",".",".","western"
49,"CS","Serbia and Montenegro",,,"CSD",,,,"western"
50,"CU","Cuba",,,"CUP",,,,"western"
51,"CV","Cape Verde",,,"CVE",,,,"western"
52,"CX","Christmas Island",,,"AUD",,,,"western"
53,"CY","Cyprus",,,"CYP",,,,"western"
54,"CZ","Czech Republic",,,"CZK"," ",",",",","western"
55,"DE","Germany",,"%n €","EUR",".",",",",","western"
56,"DJ","Djibouti",,,"DJF",,,,"western"
57,"DK","Denmark",,,"DKK",".",",",",","western"
58,"DM","Dominica",,,"XCD",,,,"western"
59,"DO","Dominican Republic",,,"DOP",",",".",".","western"
60,"DZ","Algeria",,,"DZD",",",".",".","western"
61,"EC","Ecuador",,,"USD",".",",",",","western"
62,"EE","Estonia",,,"EEK"," ",",",",","western"
63,"EG","Egypt",,,"EGP",",",".",".","western"
64,"EH","Western Sahara",,,"MAD",,,,"western"
65,"ER","Eritrea",,,"ERN",",",".",".","western"
66,"ES","Spain",,"%n €","EUR",".",",",",","western"
67,"ET","Ethiopia",,,"ETB",",",".",".","western"
68,"FI","Finland",,,"EUR"," ",",",",","western"
69,"FJ","Fiji",,,"FJD",,,,"western"
70,"FK","Falkland Islands",,,"FKP",,,,"western"
71,"FM","Micronesia",,,"USD",,,,"western"
72,"FO","Faeroe Islands",,,"DKK",".",",",",","western"
73,"FR","France",,"%n €","EUR",,",",",","western"
74,"GA","Gabon",,,"XAF",,,,"western"
75,"GB","United Kingdom",,"£%n","GBP",",",".",".","western"
76,"GD","Grenada",,,"XCD",,,,"western"
77,"GE","Georgia",,,"GEL",".",",",",","western"
78,"GF","French Guiana",,,"EUR",,,,"western"
79,"GH","Ghana",,,"GHC",,,,"western"
80,"GI","Gibraltar",,,"GIP",,,,"western"
81,"GL","Greenland",,,"DKK",".",",",",","western"
82,"GM","Gambia",,,"GMD",,,,"western"
83,"GN","Guinea",,,"GNS",,,,"western"
84,"GP","Guadaloupe",,,"EUR",,,,"western"
85,"GQ","Equatorial Guinea",,,"XAF",,,,"western"
86,"GR","Greece",,,"EUR",".",",",",","western"
87,"GS","South Georgia and the South Sandwich Islands",,,"GBP",,,,"western"
88,"GT","Guatemala",,,"GTQ",",",".",".","western"
89,"GU","Guam",,,"USD",,,,"western"
90,"GW","Guinea-Bissau",,,"GWP",,,,"western"
91,"GY","Guyana",,,"GYD",,,,"western"
92,"HK","Hong Kong",,"HK$%n","HKD",",",".",".","western"
93,"HM","Heard and McDonald Islands",,,"AUD",,,,"western"
94,"HN","Honduras",,,"HNL",",",".",".","western"
95,"HR","Hrvatska",,,"HRK",,",",",","western"
96,"HT","Haiti",,,"HTG",,,,"western"
97,"HU","Hungary",,,"HUF",".",",",",","western"
98,"ID","Indonesia",,,"IDR",".",",",",","western"
99,"IE","Ireland",,,"EUR",",",".",".","western"
100,"IL","Israel",,"%n ₪","ILS",",",".",".","western"
101,"IN","India",,"Rs.%n","INR",",",".",".","indian"
102,"IO","British Indian Ocean Territory",,,"GBP",,,,"western"
103,"IQ","Iraq",,,"IQD",",",".",".","western"
104,"IR","Iran",,,"IRR","٬","٫","٫","western"
105,"IS","Iceland",,,"ISK",".",",",",","western"
106,"IT","Italy",,"€ %n","EUR",".",",",",","western"
107,"JM","Jamaica",,,"JMD",,,,"western"
108,"JO","Jordan",,,"JOD",",",".",".","western"
109,"JP","Japan",,"¥%n","JPY",",",".",".","western"
110,"KE","Kenya",,,"KES",,,,"western"
111,"KG","Kyrgyz Republic",,,"KGS",,,,"western"
112,"KH","Cambodia",,,"KHR",,,,"western"
113,"KI","Kiribati",,,"AUD",,,,"western"
114,"KM","Comoros",,,"KMF",,,,"western"
115,"KN","St. Kitts and Nevis",,,"XCD",,,,"western"
116,"KP","Korea",,,"KPW",,,,"western"
117,"KR","Korea",,,"KRW",",",".",".","western"
118,"KW","Kuwait",,,"KWD",",",".",".","western"
119,"KY","Cayman Islands",,,"KYD",,,,"western"
120,"KZ","Kazakhstan",,,"KZT",,,,"western"
121,"LA","Lao People's Democratic Republic",,,"LAK",",",".",".","western"
122,"LB","Lebanon",,,"LBP",",",".",".","western"
123,"LC","St. Lucia",,,"XCD",,,,"western"
124,"LI","Liechtenstein",,,"CHF",,,,"western"
125,"LK","Sri Lanka",,,"LKR",,,,"western"
126,"LR","Liberia",,,"LRD",,,,"western"
127,"LS","Lesotho",,,"LSL",,,,"western"
128,"LT","Lithuania",,,"LTL",".",",",",","western"
129,"LU","Luxembourg",,,"EUR",".",",",",","western"
130,"LV","Latvia",,,"LVL"," ",",",",","western"
131,"LY","Libyan Arab Jamahiriya",,,"LYD",",",".",".","western"
132,"MA","Morocco",,,"MAD",",",".",".","western"
133,"MC","Monaco",,,"EUR",,,,"western"
134,"MD","Moldova",,,"MDL",,,,"western"
135,"MG","Madagascar",,,"MGF",,,,"western"
136,"MH","Marshall Islands",,,"USD",,,,"western"
137,"MK","Macedonia",,,"MKD",,",",",","western"
138,"ML","Mali",,,"XAF",,,,"western"
139,"MM","Myanmar",,,,,,,"western"
140,"MN","Mongolia",,,"MNT",,".",".","western"
141,"MO","Macao",,,"MOP",,,,"western"
142,"MP","Northern Mariana Islands",,,"USD",,,,"western"
143,"MQ","Martinique",,,"EUR",,,,"western"
144,"MR","Mauritania",,,"MRO",,,,"western"
145,"MS","Montserrat",,,"XCD",,,,"western"
146,"MT","Malta",,,"MTL",",",".",".","western"
147,"MU","Mauritius",,,"MUR",,,,"western"
148,"MV","Maldives",,,"MVR",,,,"western"
149,"MW","Malawi",,,"MWK",,,,"western"
150,"MX","Mexico",,,"MXN",",",".",".","western"
151,"MY","Malaysia",,,"MYR",",",".",".","western"
152,"MZ","Mozambique",,,"MZM",,,,"western"
153,"NA","Namibia",,,"NAD",,,,"western"
154,"NC","New Caledonia",,,"XPF",,,,"western"
155,"NE","Niger",,,"XOF",,,,"western"
156,"NF","Norfolk Island",,,"AUD",,,,"western"
157,"NG","Nigeria",,,"NGN",,,,"western"
158,"NI","Nicaragua",,,"NIC",",",".",".","western"
159,"NL","Netherlands",,"€ %n","EUR",,",",",","western"
160,"NO","Norway",,"kr %n","NOK"," ",",",",","western"
161,"NP","Nepal",,,"NPR",",",".",".","western"
162,"NR","Nauru",,,"AUD",,,,"western"
163,"NU","Niue",,,"NZD",,,,"western"
164,"NZ","New Zealand",,,"NZD",",",".",".","western"
165,"OM","Oman",,,"OMR",",",".",".","western"
166,"PA","Panama",,,"PAB",",",".",".","western"
167,"PE","Peru",,,"PEI",",",".",".","western"
168,"PF","French Polynesia",,,"XPF",,,,"western"
169,"PG","Papua New Guinea",,,"PGK",,,,"western"
170,"PH","Philippines",,,"PHP",",",".",".","western"
171,"PK","Pakistan",,,"PKR",",",".",".","western"
172,"PL","Poland",,,"PLN",".",",",",","western"
173,"PM","St. Pierre and Miquelon",,,"EUR",,,,"western"
174,"PN","Pitcairn Island",,,"NZD",,,,"western"
175,"PR","Puerto Rico",,,"USD",",",".",".","western"
176,"PS","Palestinian Territory",,,,,,,"western"
177,"PT","Portugal",,"%n €","EUR",".","$","$","western"
178,"PW","Palau",,,"USD",,,,"western"
179,"PY","Paraguay",,,"PYG",".",",",",","western"
180,"QA","Qatar",,,"QAR",",",".",".","western"
181,"RE","Reunion",,,"EUR",,,,"western"
182,"RO","Romania",,,"ROL",".",",",",","western"
183,"RU","Russian Federation",,,"RUB",,".",".","western"
184,"RW","Rwanda",,,"RWF",,,,"western"
185,"SA","Saudi Arabia",,,"SAR",,".",".","western"
186,"SB","Solomon Islands",,,"SBD",,,,"western"
187,"SC","Seychelles",,,"SCR",,,,"western"
188,"SD","Sudan",,,"SDP",",",".",".","western"
189,"SE","Sweden",,"%n kr","SEK",,",",",","western"
190,"SG","Singapore",,,"SGD",",",".",".","western"
191,"SH","St. Helena",,,"SHP",,,,"western"
192,"SI","Slovenia",,,"SIT",,",",",","western"
193,"SJ","Svalbard & Jan Mayen Islands",,,"NOK",,,,"western"
194,"SK","Slovakia",,,"SKK"," ",",",",","western"
195,"SL","Sierra Leone",,,"SLL",,,,"western"
196,"SM","San Marino",,,"EUR",,,,"western"
197,"SN","Senegal",,,"XOF",,,,"western"
198,"SO","Somalia",,,"SOS",,,,"western"
199,"SR","Suriname",,,"SRG",,,,"western"
200,"ST","Sao Tome and Principe",,,"STD",,,,"western"
201,"SV","El Salvador",,,"SVC",",",".",".","western"
202,"SY","Syrian Arab Republic",,,"SYP",",",".",".","western"
203,"SZ","Swaziland",,,"SZL",,,,"western"
204,"TC","Turks and Caicos Islands",,,"USD",,,,"western"
205,"TD","Chad",,,"XAF",,,,"western"
206,"TF","French Southern Territories",,,"EUR",,,,"western"
207,"TG","Togo",,,"XAF",,,,"western"
208,"TH","Thailand",,,"THB",",",".",".","western"
209,"TJ","Tajikistan",,,"TJR",,".",".","western"
210,"TK","Tokelau",,,"NZD",,,,"western"
211,"TL","Timor-Leste",,,,,,,"western"
212,"TM","Turkmenistan",,,"TMM",,,,"western"
213,"TN","Tunisia",,,"TND",",",".",".","western"
214,"TO","Tonga",,,"TOP",,,,"western"
215,"TR","Turkey",,,"TRL",".",",",",","western"
216,"TT","Trinidad and Tobago",,,"TTD",,,,"western"
217,"TV","Tuvalu",,,"AUD",,,,"western"
218,"TW","Taiwan",,"NT$%n","TWD",",",".",".","western"
219,"TZ","Tanzania",,,"TZS",,,,"western"
220,"UA","Ukraine",,,"UAH",,".",".","western"
221,"UG","Uganda",,,"UGS",",",".",".","western"
222,"UM","United States Minor Outlying Islands",,,"USD",,,,"western"
223,"US","United States of America",,,"USD",",",".",".","western"
224,"UY","Uruguay",,,"UYU",".",",",",","western"
225,"UZ","Uzbekistan",,,"UZS",",",".",".","western"
226,"VA","Holy See",,,"EUR",,,,"western"
227,"VC","St. Vincent and the Grenadines",,,"XCD",,,,"western"
228,"VE","Venezuela",,,"VEB",".",",",",","western"
229,"VG","British Virgin Islands",,,"USD",,,,"western"
230,"VI","US Virgin Islands",,,"USD",,,,"western"
231,"VN","Viet Nam",,,"VND",".",",",",","western"
232,"VU","Vanuatu",,,"VUV",,,,"western"
233,"WF","Wallis and Futuna Islands",,,"XPF",,,,"western"
234,"WS","Samoa",,,"WST",,,,"western"
235,"YE","Yemen",,,,",",".",".","western"
236,"YT","Mayotte",,,"EUR",,,,"western"
237,"ZA","South Africa",,,"ZAR",",",".",".","western"
238,"ZM","Zambia",,,"ZMK",,,,"western"
239,"ZW","Zimbabwe",,,"ZWD",",",".",".","western"
END_OF_DATA
  end

  def self.language_data
    <<'END_OF_DATA'
"id","iso_639_1","iso_639_2","iso_639_3","rfc_3066","english_name","english_name_locale","english_name_modifier","native_name","native_name_locale","native_name_modifier","macro_language","direction","pluralization","scope"

15,"aa","aar","aar",,"Afar",,,,,,0,"ltr",,"L"
33,"ab","abk","abk",,"Abkhazian",,,"аҧсуа бызшәа",,,0,"ltr",,"L"
114,"af","afr","afr",,"Afrikaans",,,"Afrikaans",,,0,"ltr",,"L"
191,"ak","aka","aka",,"Akan",,,,,,1,"ltr",,"L"
247,"am","amh","amh",,"Amharic",,,"አማርኛ",,,0,"ltr",,"L"
340,"ar","ara","ara",,"Arabic",,,"العربية",,,1,"rtl",,"L"
346,"an","arg","arg",,"Aragonese",,,,,,0,"ltr",,"L"
376,"as","asm","asm",,"Assamese",,,,,,0,"ltr",,"L"
438,"av","ava","ava",,"Avaric",,,,,,0,"ltr",,"L"
441,"ae","ave","ave",,"Avestan",,,,,,0,"ltr",,"A"
483,"ay","aym","aym",,"Aymara",,,,,,1,"ltr",,"L"
496,"az","aze","aze",,"Azerbaijani",,,"azərbaycan",,,1,"ltr",,"L"
512,"ba","bak","bak",,"Bashkir",,,,,,0,"ltr",,"L"
514,"bm","bam","bam",,"Bambara",,,"Bamanankan",,,0,"ltr",,"L"
614,"be","bel","bel",,"Belarusian",,,"Беларуская",,,0,"ltr",,"L"
616,"bn","ben","ben",,"Bengali",,,,,,0,"ltr",,"L"
721,"bi","bis","bis",,"Bislama",,,,,,0,"ltr",,"L"
860,"bo","bod","bod",,"Tibetan",,,,,,0,"ltr",,"L"
875,"bs","bos","bos",,"Bosnian",,,,,,0,"ltr",,"L"
936,"br","bre","bre",,"Breton",,,,,,0,"ltr",,"L"
1020,"bg","bul","bul",,"Bulgarian",,,"Български",,,0,"ltr",,"L"
1177,"ca","cat","cat",,"Catalan",,,"Català",,,0,"ltr",,"L"
1233,"cs","ces","ces",,"Czech",,,"čeština",,,0,"ltr","c%10==1 && c%100!=11 ? 1 : c%10>=2 && c%10<=4 && (c%100<10 || c%100>=20) ? 2 : 3","L"
1242,"ch","cha","cha",,"Chamorro",,,,,,0,"ltr",,"L"
1246,"ce","che","che",,"Chechen",,,,,,0,"ltr",,"L"
1261,"cu","chu","chu",,"Slavic",,"Church",,,,0,"ltr",,"A"
1262,"cv","chv","chv",,"Chuvash",,,,,,0,"ltr",,"L"
1372,"kw","cor","cor",,"Cornish",,,,,,0,"ltr",,"L"
1373,"co","cos","cos",,"Corsican",,,,,,0,"ltr",,"L"
1397,"cr","cre","cre",,"Cree",,,,,,1,"ltr",,"L"
1481,"cy","cym","cym",,"Welsh",,,"Cymraeg",,,0,"ltr",,"L"
1499,"da","dan","dan",,"Danish",,,"Dansk",,,0,"ltr","c == 1 ? 1 : 2","L"
1556,"de","deu","deu",,"German",,,"Deutsch",,,0,"ltr","c == 1 ? 1 : 2","L"
1607,"dv","div","div",,"Divehi",,,,,,0,"ltr",,"L"
1760,"dz","dzo","dzo",,"Dzongkha",,,,,,0,"ltr",,"L"
1793,"el","ell","ell",,"Greek",,"Modern (1453-)","Ελληνικά",,,0,"ltr","c == 1 ? 1 : 2","L"
1819,"en","eng","eng",,"English",,,,,,0,"ltr","c == 1 ? 1 : 2","L"
1831,"eo","epo","epo",,"Esperanto",,,,,,0,"ltr","c == 1 ? 1 : 2","C"
1851,"et","est","est",,"Estonian",,,"Eesti",,,0,"ltr","c == 1 ? 1 : 2","L"
1865,"eu","eus","eus",,"Basque",,,"euskera",,,0,"ltr",,"L"
1869,"ee","ewe","ewe",,"Ewe",,,"Ɛʋɛ",,,0,"ltr",,"L"
1886,"fo","fao","fao",,"Faroese",,,,,,0,"ltr",,"L"
1889,"fa","fas","fas",,"Persian",,,"فارسی",,,1,"ltr",,"L"
1901,"fj","fij","fij",,"Fijian",,,,,,0,"ltr",,"L"
1903,"fi","fin","fin",,"Finnish",,,"suomi",,,0,"ltr","c == 1 ? 1 : 2","L"
1930,"fr","fra","fra",,"French",,,"français",,,0,"ltr","c == 1 ? 1 : 2","L"
1942,"fy","fry","fry",,"Frisian",,,,,,1,"ltr",,"L"
1954,"ff","ful","ful",,"Fulah",,,"Fulfulde, Pulaar, Pular",,,1,"ltr",,"L"
2112,"gd","gla","gla",,"Gaelic","Scots",,,,,0,"ltr","c==1 ? 1 : c==2 ? 2 : 3","L"
2115,"ga","gle","gle",,"Irish",,,"Gaeilge",,,0,"ltr","c==1 ? 1 : c==2 ? 2 : 3","L"
2116,"gl","glg","glg",,"Gallegan",,,"Galego",,,0,"ltr",,"L"
2125,"gv","glv","glv",,"Manx",,,,,,0,"ltr",,"E"
2194,"gn","grn","grn",,"Guarani",,,,,,1,"ltr",,"L"
2226,"gu","guj","guj",,"Gujarati",,,,,,0,"ltr",,"L"
2304,"ht","hat","hat",,"Haitian; Haitian Creole",,,,,,0,"ltr",,"L"
2305,"ha","hau","hau",,"Hausa",,,"Hausa",,,0,"ltr",,"L"
2315,"sh",,"hbs",,"Serbo-Croatian",,,,,,1,"ltr",,"L"
2323,"he","heb","heb",,"Hebrew",,,"עברית",,,0,"rtl","c == 1 ? 1 : 2","L"
2329,"hz","her","her",,"Herero",,,,,,0,"ltr",,"L"
2343,"hi","hin","hin",,"Hindi",,,"हिंदी",,,0,"ltr",,"L"
2370,"ho","hmo","hmo",,"Hiri Motu",,,,,,0,"ltr",,"L"
2418,"hr","hrv","hrv",,"Croatian",,,"Hrvatski",,,0,"ltr","c%10==1 && c%100!=11 ? 1 : c%10>=2 && c%10<=4 && (c%100<10 || c%100>=20) ? 2 : 3","L"
2443,"hu","hun","hun",,"Hungarian",,,"Magyar",,,0,"ltr","c = 1","L"
2466,"hy","hye","hye",,"Armenian",,,"Հայերեն",,,0,"ltr",,"L"
2480,"ig","ibo","ibo",,"Igbo",,,,,,0,"ltr",,"L"
2494,"io","ido","ido",,"Ido",,,,,,0,"ltr",,"C"
2519,"ii","iii","iii",,"Yi",,"Sichuan",,,,0,"ltr",,"L"
2532,"iu","iku","iku",,"Inuktitut",,,,,,1,"ltr",,"L"
2539,"ie","ile","ile",,"Interlingue",,,,,,0,"ltr",,"C"
2556,"ia","ina","ina",,"Interlingua","International Auxiliary Language Association",,,,,0,"ltr",,"C"
2558,"id","ind","ind",,"Indonesian",,,"Bahasa indonesia",,,0,"ltr",,"L"
2574,"ik","ipk","ipk",,"Inupiaq",,,,,,1,"ltr",,"L"
2593,"is","isl","isl",,"Icelandic",,,"Íslenska",,,0,"ltr",,"L"
2600,"it","ita","ita",,"Italian",,,"italiano",,,0,"ltr","c == 1 ? 1 : 2","L"
2652,"jv","jav","jav",,"Javanese",,,,,,0,"ltr",,"L"
2723,"ja","jpn","jpn",,"Japanese",,,"日本語",,,0,"ltr","c = 1","L"
2763,"kl","kal","kal",,"Kalaallisut",,,,,,0,"ltr",,"L"
2765,"kn","kan","kan",,"Kannada",,,"ಕನ್ನಡ",,,0,"ltr",,"L"
2769,"ks","kas","kas",,"Kashmiri",,,,,,0,"ltr",,"L"
2770,"ka","kat","kat",,"Georgian",,,,,,0,"ltr",,"L"
2771,"kr","kau","kau",,"Kanuri",,,,,,1,"ltr",,"L"
2776,"kk","kaz","kaz",,"Kazakh",,,"Қазақ",,,0,"ltr",,"L"
2939,"km","khm","khm",,"Khmer",,,,,,0,"ltr",,"L"
2963,"ki","kik","kik",,"Kikuyu",,,,,,0,"ltr",,"L"
2966,"rw","kin","kin",,"Kinyarwanda",,,"Kinyarwanda",,,0,"ltr",,"L"
2970,"ky","kir","kir",,"Kirghiz",,,"Кыргыз",,,0,"ltr",,"L"
3117,"kv","kom","kom",,"Komi",,,,,,1,"ltr",,"L"
3118,"kg","kon","kon",,"Kongo",,,,,,1,"ltr",,"L"
3122,"ko","kor","kor",,"Korean",,,"한국어",,,0,"ltr","c = 1","L"
3260,"kj","kua","kua",,"Kuanyama",,,,,,0,"ltr",,"L"
3276,"ku","kur","kur",,"Kurdish",,,,,,1,"ltr",,"L"
3428,"lo","lao","lao",,"Lao",,,,,,0,"ltr",,"L"
3433,"la","lat","lat",,"Latin",,,,,,0,"ltr",,"A"
3435,"lv","lav","lav",,"Latvian",,,"Latviešu",,,0,"ltr","c%10==1 && c%100!=11 ? 1 : c != 0 ? 2 : 3","L"
3546,"li","lim","lim",,"Limburgish",,"Limburger",,,,0,"ltr",,"L"
3547,"ln","lin","lin",,"Lingala",,,,,,0,"ltr",,"L"
3553,"lt","lit","lit",,"Lithuanian",,,"Lietuviškai",,,0,"ltr","c%10==1 && c%100!=11 ? 1 : c%10>=2 && (c%100<10 || c%100>=20) ? 2 : 3","L"
3687,"lb","ltz","ltz",,"Letzeburgesch",,,,,,0,"ltr",,"L"
3689,"lu","lub","lub",,"Luba-Katanga",,,,,,0,"ltr",,"L"
3694,"lg","lug","lug",,"Ganda",,,,,,0,"ltr",,"L"
3732,"mh","mah","mah",,"Marshall",,,,,,0,"ltr",,"L"
3736,"ml","mal","mal",,"Malayalam",,,,,,0,"ltr",,"L"
3740,"mr","mar","mar",,"Marathi",,,,,,0,"ltr",,"L"
3981,"mk","mkd","mkd",,"Macedonian",,,"Македонски",,,0,"ltr",,"L"
4009,"mg","mlg","mlg",,"Malagasy",,,,,,1,"ltr",,"L"
4022,"mt","mlt","mlt",,"Maltese",,,"Malti",,,0,"ltr",,"L"
4091,"mo","mol","mol",,"Moldavian",,,,,,0,"ltr",,"L"
4093,"mn","mon","mon",,"Mongolian",,,,,,1,"ltr",,"L"
4166,"mi","mri","mri",,"Maori",,,,,,0,"ltr",,"L"
4184,"ms","msa","msa",,"Malay","generic",,"Bahasa melayu",,,1,"ltr",,"L"
4338,"my","mya","mya",,"Burmese",,,,,,0,"ltr",,"L"
4406,"na","nau","nau",,"Nauru",,,,,,0,"ltr",,"L"
4407,"nv","nav","nav",,"Navajo",,,,,,0,"ltr",,"L"
4423,"nr","nbl","nbl",,"Ndebele",,"South",,,,0,"ltr",,"L"
4463,"nd","nde","nde",,"Ndebele",,"North",,,,0,"ltr",,"L"
4473,"ng","ndo","ndo",,"Ndonga",,,,,,0,"ltr",,"L"
4499,"ne","nep","nep",,"Nepali",,,,,,0,"ltr",,"L"
4628,"nl","nld","nld",,"Dutch",,,"Nederlands",,,0,"ltr","c == 1 ? 1 : 2","L"
4682,"nn","nno","nno",,"Norwegian Nynorsk",,,,,,0,"ltr",,"L"
4695,"nb","nob","nob",,"Norwegian Bokmål",,,,,,0,"ltr",,"L"
4709,"no","nor","nor",,"Norwegian",,,"Norsk",,,1,"ltr","c == 1 ? 1 : 2","L"
4821,"ny","nya","nya",,"Chichewa; Nyanja",,,,,,0,"ltr",,"L"
4867,"oc","oci","oci",,"Occitan","post 1500",,,,,1,"ltr",,"L"
4891,"oj","oji","oji",,"Ojibwa",,,,,,1,"ltr",,"L"
4965,"or","ori","ori",,"Oriya",,,,,,0,"ltr",,"L"
4967,"om","orm","orm",,"Oromo",,,,,,1,"ltr",,"L"
4984,"os","oss","oss",,"Ossetian; Ossetic",,,,,,0,"ltr",,"L"
5031,"pa","pan","pan",,"Panjabi",,,,,,0,"ltr",,"L"
5176,"pi","pli","pli",,"Pali",,,,,,0,"ltr",,"A"
5244,"pl","pol","pol",,"Polish",,,"Polski",,,0,"ltr","c==1 ? 1 : c%10>=2 && c%10<=4 && (c%100<10 || c%100>=20) ? 2 : 3","L"
5250,"pt","por","por",,"Portuguese",,,"português",,,0,"ltr","c == 1 ? 1 : 2","L"
5343,"ps","pus","pus",,"Pushto",,,"پښتو",,,1,"ltr",,"L"
5368,"qu","que","que",,"Quechua",,,,,,1,"ltr",,"L"
5525,"rm","roh","roh",,"Raeto-Romance",,,,,,0,"ltr",,"L"
5528,"ro","ron","ron",,"Romanian",,,"Română",,,0,"ltr",,"L"
5552,"rn","run","run",,"Rundi",,,"Kirundi",,,0,"ltr",,"L"
5556,"ru","rus","rus",,"Russian",,,"Pyccĸий",,,0,"ltr","c%10==1 && c%100!=11 ? 1 : c%10>=2 && c%10<=4 && (c%100<10 || c%100>=20) ? 2 : 3","L"
5576,"sg","sag","sag",,"Sango",,,,,,0,"ltr",,"L"
5581,"sa","san","san",,"Sanskrit",,,,,,0,"ltr",,"A"
5738,"si","sin","sin",,"Sinhalese",,,,,,0,"ltr",,"L"
5800,"sk","slk","slk",,"Slovak",,,"Slovenčina",,,0,"ltr","c%10==1 && c%100!=11 ? 1 : c%10>=2 && c%10<=4 && (c%100<10 || c%100>=20) ? 2 : 3","L"
5810,"sl","slv","slv",,"Slovenian",,,"Slovenščina",,,0,"ltr","c%100==1 ? 1 : c%100==2 ? 2 : c%100==3 || c%100==4 ? 3 : 4","L"
5819,"se","sme","sme",,"Northern Sami",,,,,,0,"ltr",,"L"
5828,"sm","smo","smo",,"Samoan",,,,,,0,"ltr",,"L"
5840,"sn","sna","sna",,"Shona",,,,,,0,"ltr",,"L"
5843,"sd","snd","snd",,"Sindhi",,,,,,0,"ltr",,"L"
5876,"so","som","som",,"Somali",,,"Somali",,,0,"ltr",,"L"
5882,"st","sot","sot",,"Sotho",,"Southern",,,,0,"ltr",,"L"
5889,"es","spa","spa",,"Spanish",,,"Español",,,0,"ltr","c == 1 ? 1 : 2","L"
5910,"sq","sqi","sqi",,"Albanian",,,"shqip",,,1,"ltr",,"L"
5921,"sc","srd","srd",,"Sardinian",,,,,,1,"ltr",,"L"
5933,"sr","srp","srp",,"Serbian",,,"Srpski",,,0,"ltr",,"L"
5964,"ss","ssw","ssw",,"Swati",,,,,,0,"ltr",,"L"
6002,"su","sun","sun",,"Sundanese",,,,,,0,"ltr",,"L"
6021,"sw","swa","swa",,"Swahili","generic",,"Kiswahili",,,1,"ltr",,"L"
6024,"sv","swe","swe",,"Swedish",,,"svenska",,,0,"ltr","c == 1 ? 1 : 2","L"
6086,"ty","tah","tah",,"Tahitian",,,,,,0,"ltr",,"L"
6090,"ta","tam","tam",,"Tamil",,,,,,0,"ltr",,"L"
6097,"tt","tat","tat",,"Tatar",,,,,,0,"ltr",,"L"
6182,"te","tel","tel",,"Telugu",,,"తెలుగు",,,0,"ltr",,"L"
6210,"tg","tgk","tgk",,"Tajik",,,,,,0,"ltr",,"L"
6211,"tl","tgl","tgl",,"Tagalog",,,,,,0,"ltr",,"L"
6223,"th","tha","tha",,"Thai",,,"ภาษาไทย",,,0,"ltr",,"L"
6260,"ti","tir","tir",,"Tigrinya",,,,,,0,"ltr",,"L"
6383,"to","ton","ton",,"Tonga","Tonga Islands",,,,,0,"ltr",,"L"
6466,"tn","tsn","tsn",,"Tswana",,,,,,0,"ltr",,"L"
6467,"ts","tso","tso",,"Tsonga",,,,,,0,"ltr",,"L"
6513,"tk","tuk","tuk",,"Turkmen",,,,,,0,"ltr",,"L"
6519,"tr","tur","tur",,"Turkish",,,"Tϋrkçe",,,0,"ltr","c = 1","L"
6546,"tw","twi","twi",,"Twi",,,,,,0,"ltr",,"L"
6630,"ug","uig","uig",,"Uighur",,,,,,0,"ltr",,"L"
6640,"uk","ukr","ukr",,"Ukrainian",,,"Українська",,,0,"ltr","c%10==1 && c%100!=11 ? 1 : c%10>=2 && c%10<=4 && (c%100<10 || c%100>=20) ? 2 : 3","L"
6679,"ur","urd","urd",,"Urdu",,,"اردو",,,0,"ltr",,"L"
6719,"uz","uzb","uzb",,"Uzbek",,,"o'zbek",,,1,"ltr",,"L"
6744,"ve","ven","ven",,"Venda",,,,,,0,"ltr",,"L"
6751,"vi","vie","vie",,"Vietnamese",,,"Tiếng Việt",,,0,"ltr",,"L"
6800,"vo","vol","vol",,"Volapük",,,,,,0,"ltr",,"C"
6911,"wa","wln","wln",,"Walloon",,,,,,0,"ltr",,"L"
6952,"wo","wol","wol",,"Wolof",,,"Wolof",,,0,"ltr",,"L"
7078,"xh","xho","xho",,"Xhosa",,,,,,0,"ltr",,"L"
7324,"yi","yid","yid",,"Yiddish",,,,,,1,"ltr",,"L"
7481,"za","zha","zha",,"Zhuang",,,,,,1,"ltr",,"L"
7484,"zh","zho","zho",,"Chinese",,,"中文",,,1,"ltr",,"L"
7594,"zu","zul","zul",,"Zulu",,,"isiZulu",,,0,"ltr",,"L"
END_OF_DATA
  end

  def self.translation_data
    <<'END_OF_DATA'
"id","type","tr_key","table_name","item_id","facet","language_id","text","pluralization_index"
3611,"ViewTranslation","Sunday [weekday]","",,"",114,"Sondag",1
3612,"ViewTranslation","Monday [weekday]","",,"",114,"Maandag",1
3613,"ViewTranslation","Tuesday [weekday]","",,"",114,"Dinsdag",1
3614,"ViewTranslation","Wednesday [weekday]","",,"",114,"Woensdag",1
3615,"ViewTranslation","Thursday [weekday]","",,"",114,"Donderdag",1
3616,"ViewTranslation","Friday [weekday]","",,"",114,"Vrydag",1
3617,"ViewTranslation","Saturday [weekday]","",,"",114,"Saterdag",1
3618,"ViewTranslation","Sun [abbreviated weekday]","",,"",114,"So",1
3619,"ViewTranslation","Mon [abbreviated weekday]","",,"",114,"Ma",1
3620,"ViewTranslation","Tue [abbreviated weekday]","",,"",114,"Di",1
3621,"ViewTranslation","Wed [abbreviated weekday]","",,"",114,"Wo",1
3622,"ViewTranslation","Thu [abbreviated weekday]","",,"",114,"Do",1
3623,"ViewTranslation","Fri [abbreviated weekday]","",,"",114,"Vr",1
3624,"ViewTranslation","Sat [abbreviated weekday]","",,"",114,"Sa",1
3625,"ViewTranslation","January [month]","",,"",114,"Januarie",1
3626,"ViewTranslation","February [month]","",,"",114,"Februarie",1
3627,"ViewTranslation","March [month]","",,"",114,"Maart",1
3628,"ViewTranslation","April [month]","",,"",114,"April",1
3629,"ViewTranslation","May [month]","",,"",114,"Mei",1
3630,"ViewTranslation","June [month]","",,"",114,"Junie",1
3631,"ViewTranslation","July [month]","",,"",114,"Julie",1
3632,"ViewTranslation","August [month]","",,"",114,"Augustus",1
3633,"ViewTranslation","September [month]","",,"",114,"September",1
3634,"ViewTranslation","October [month]","",,"",114,"Oktober",1
3635,"ViewTranslation","November [month]","",,"",114,"November",1
3636,"ViewTranslation","December [month]","",,"",114,"Desember",1
3637,"ViewTranslation","Jan [abbreviated month]","",,"",114,"Jan",1
3638,"ViewTranslation","Feb [abbreviated month]","",,"",114,"Feb",1
3639,"ViewTranslation","Mar [abbreviated month]","",,"",114,"Mar",1
3640,"ViewTranslation","Apr [abbreviated month]","",,"",114,"Apr",1
3641,"ViewTranslation","May [abbreviated month]","",,"",114,"Mei",1
3642,"ViewTranslation","Jun [abbreviated month]","",,"",114,"Jun",1
3643,"ViewTranslation","Jul [abbreviated month]","",,"",114,"Jul",1
3644,"ViewTranslation","Aug [abbreviated month]","",,"",114,"Aug",1
3645,"ViewTranslation","Sep [abbreviated month]","",,"",114,"Sep",1
3646,"ViewTranslation","Oct [abbreviated month]","",,"",114,"Okt",1
3647,"ViewTranslation","Nov [abbreviated month]","",,"",114,"Nov",1
3648,"ViewTranslation","Dec [abbreviated month]","",,"",114,"Des",1
3649,"ViewTranslation","Sunday [weekday]","",,"",247,"እሑድ",1
3650,"ViewTranslation","Monday [weekday]","",,"",247,"ሰኞ",1
3651,"ViewTranslation","Tuesday [weekday]","",,"",247,"ማክሰኞ",1
3652,"ViewTranslation","Wednesday [weekday]","",,"",247,"ረቡዕ",1
3653,"ViewTranslation","Thursday [weekday]","",,"",247,"ሐሙስ",1
3654,"ViewTranslation","Friday [weekday]","",,"",247,"ዓርብ",1
3655,"ViewTranslation","Saturday [weekday]","",,"",247,"ቅዳሜ",1
3656,"ViewTranslation","Sun [abbreviated weekday]","",,"",247,"እሑድ",1
3657,"ViewTranslation","Mon [abbreviated weekday]","",,"",247,"ሰኞ ",1
3658,"ViewTranslation","Tue [abbreviated weekday]","",,"",247,"ማክሰ",1
3659,"ViewTranslation","Wed [abbreviated weekday]","",,"",247,"ረቡዕ",1
3660,"ViewTranslation","Thu [abbreviated weekday]","",,"",247,"ሐሙስ",1
3661,"ViewTranslation","Fri [abbreviated weekday]","",,"",247,"ዓርብ",1
3662,"ViewTranslation","Sat [abbreviated weekday]","",,"",247,"ቅዳሜ",1
3663,"ViewTranslation","January [month]","",,"",247,"ጃንዩወሪ",1
3664,"ViewTranslation","February [month]","",,"",247,"ፌብሩወሪ",1
3665,"ViewTranslation","March [month]","",,"",247,"ማርች",1
3666,"ViewTranslation","April [month]","",,"",247,"ኤፕረል",1
3667,"ViewTranslation","May [month]","",,"",247,"ሜይ",1
3668,"ViewTranslation","June [month]","",,"",247,"ጁን",1
3669,"ViewTranslation","July [month]","",,"",247,"ጁላይ",1
3670,"ViewTranslation","August [month]","",,"",247,"ኦገስት",1
3671,"ViewTranslation","September [month]","",,"",247,"ሴፕቴምበር",1
3672,"ViewTranslation","October [month]","",,"",247,"ኦክተውበር",1
3673,"ViewTranslation","November [month]","",,"",247,"ኖቬምበር",1
3674,"ViewTranslation","December [month]","",,"",247,"ዲሴምበር",1
3675,"ViewTranslation","Jan [abbreviated month]","",,"",247,"ጃንዩ",1
3676,"ViewTranslation","Feb [abbreviated month]","",,"",247,"ፌብሩ",1
3677,"ViewTranslation","Mar [abbreviated month]","",,"",247,"ማርች",1
3678,"ViewTranslation","Apr [abbreviated month]","",,"",247,"ኤፕረ",1
3679,"ViewTranslation","May [abbreviated month]","",,"",247,"ሜይ ",1
3680,"ViewTranslation","Jun [abbreviated month]","",,"",247,"ጁን ",1
3681,"ViewTranslation","Jul [abbreviated month]","",,"",247,"ጁላይ",1
3682,"ViewTranslation","Aug [abbreviated month]","",,"",247,"ኦገስ",1
3683,"ViewTranslation","Sep [abbreviated month]","",,"",247,"ሴፕቴ",1
3684,"ViewTranslation","Oct [abbreviated month]","",,"",247,"ኦክተ",1
3685,"ViewTranslation","Nov [abbreviated month]","",,"",247,"ኖቬም",1
3686,"ViewTranslation","Dec [abbreviated month]","",,"",247,"ዲሴም",1
3687,"ViewTranslation","Sunday [weekday]","",,"",346,"Domingo",1
3688,"ViewTranslation","Monday [weekday]","",,"",346,"Luns",1
3689,"ViewTranslation","Tuesday [weekday]","",,"",346,"Martes",1
3690,"ViewTranslation","Wednesday [weekday]","",,"",346,"Miecols",1
3691,"ViewTranslation","Thursday [weekday]","",,"",346,"Chuebes",1
3692,"ViewTranslation","Friday [weekday]","",,"",346,"Biernes",1
3693,"ViewTranslation","Saturday [weekday]","",,"",346,"Sabado",1
3694,"ViewTranslation","Sun [abbreviated weekday]","",,"",346,"Dom",1
3695,"ViewTranslation","Mon [abbreviated weekday]","",,"",346,"Lun",1
3696,"ViewTranslation","Tue [abbreviated weekday]","",,"",346,"Mar",1
3697,"ViewTranslation","Wed [abbreviated weekday]","",,"",346,"Mie",1
3698,"ViewTranslation","Thu [abbreviated weekday]","",,"",346,"Chu",1
3699,"ViewTranslation","Fri [abbreviated weekday]","",,"",346,"Bie",1
3700,"ViewTranslation","Sat [abbreviated weekday]","",,"",346,"Sab",1
3701,"ViewTranslation","January [month]","",,"",346,"Chinero",1
3702,"ViewTranslation","February [month]","",,"",346,"Frebero",1
3703,"ViewTranslation","March [month]","",,"",346,"Marzo",1
3704,"ViewTranslation","April [month]","",,"",346,"Abril",1
3705,"ViewTranslation","May [month]","",,"",346,"Mayo",1
3706,"ViewTranslation","June [month]","",,"",346,"Chunio",1
3707,"ViewTranslation","July [month]","",,"",346,"Chulio",1
3708,"ViewTranslation","August [month]","",,"",346,"Agosto",1
3709,"ViewTranslation","September [month]","",,"",346,"Setiembre",1
3710,"ViewTranslation","October [month]","",,"",346,"Octubre",1
3711,"ViewTranslation","November [month]","",,"",346,"Nobiembre",1
3712,"ViewTranslation","December [month]","",,"",346,"Abiento",1
3713,"ViewTranslation","Jan [abbreviated month]","",,"",346,"Chi",1
3714,"ViewTranslation","Feb [abbreviated month]","",,"",346,"Fre",1
3715,"ViewTranslation","Mar [abbreviated month]","",,"",346,"Mar",1
3716,"ViewTranslation","Apr [abbreviated month]","",,"",346,"Abr",1
3717,"ViewTranslation","May [abbreviated month]","",,"",346,"May",1
3718,"ViewTranslation","Jun [abbreviated month]","",,"",346,"Chn",1
3719,"ViewTranslation","Jul [abbreviated month]","",,"",346,"Chl",1
3720,"ViewTranslation","Aug [abbreviated month]","",,"",346,"Ago",1
3721,"ViewTranslation","Sep [abbreviated month]","",,"",346,"Set",1
3722,"ViewTranslation","Oct [abbreviated month]","",,"",346,"Oct",1
3723,"ViewTranslation","Nov [abbreviated month]","",,"",346,"Nob",1
3724,"ViewTranslation","Dec [abbreviated month]","",,"",346,"Abi",1
3725,"ViewTranslation","Sunday [weekday]","",,"",340,"الأحد",1
3726,"ViewTranslation","Monday [weekday]","",,"",340,"الاثنين",1
3727,"ViewTranslation","Tuesday [weekday]","",,"",340,"الثلاثاء",1
3728,"ViewTranslation","Wednesday [weekday]","",,"",340,"الأربعاء",1
3729,"ViewTranslation","Thursday [weekday]","",,"",340,"الخميس",1
3730,"ViewTranslation","Friday [weekday]","",,"",340,"الجمعة",1
3731,"ViewTranslation","Saturday [weekday]","",,"",340,"السبت",1
3732,"ViewTranslation","Sun [abbreviated weekday]","",,"",340,"ح",1
3733,"ViewTranslation","Mon [abbreviated weekday]","",,"",340,"ن",1
3734,"ViewTranslation","Tue [abbreviated weekday]","",,"",340,"ث",1
3735,"ViewTranslation","Wed [abbreviated weekday]","",,"",340,"ر",1
3736,"ViewTranslation","Thu [abbreviated weekday]","",,"",340,"خ",1
3737,"ViewTranslation","Fri [abbreviated weekday]","",,"",340,"ج",1
3738,"ViewTranslation","Sat [abbreviated weekday]","",,"",340,"س",1
3739,"ViewTranslation","January [month]","",,"",340,"يناير",1
3740,"ViewTranslation","February [month]","",,"",340,"فبراير",1
3741,"ViewTranslation","March [month]","",,"",340,"مارس",1
3742,"ViewTranslation","April [month]","",,"",340,"أبريل",1
3743,"ViewTranslation","May [month]","",,"",340,"مايو",1
3744,"ViewTranslation","June [month]","",,"",340,"يونيو",1
3745,"ViewTranslation","July [month]","",,"",340,"يوليو",1
3746,"ViewTranslation","August [month]","",,"",340,"أغسطس",1
3747,"ViewTranslation","September [month]","",,"",340,"سبتمبر",1
3748,"ViewTranslation","October [month]","",,"",340,"أكتوبر",1
3749,"ViewTranslation","November [month]","",,"",340,"نوفمبر",1
3750,"ViewTranslation","December [month]","",,"",340,"ديسمبر",1
3751,"ViewTranslation","Jan [abbreviated month]","",,"",340,"ينا",1
3752,"ViewTranslation","Feb [abbreviated month]","",,"",340,"فبر",1
3753,"ViewTranslation","Mar [abbreviated month]","",,"",340,"مار",1
3754,"ViewTranslation","Apr [abbreviated month]","",,"",340,"أبر",1
3755,"ViewTranslation","May [abbreviated month]","",,"",340,"ماي",1
3756,"ViewTranslation","Jun [abbreviated month]","",,"",340,"يون",1
3757,"ViewTranslation","Jul [abbreviated month]","",,"",340,"يول",1
3758,"ViewTranslation","Aug [abbreviated month]","",,"",340,"أغس",1
3759,"ViewTranslation","Sep [abbreviated month]","",,"",340,"سبت",1
3760,"ViewTranslation","Oct [abbreviated month]","",,"",340,"أكت",1
3761,"ViewTranslation","Nov [abbreviated month]","",,"",340,"نوف",1
3762,"ViewTranslation","Dec [abbreviated month]","",,"",340,"ديس",1
3763,"ViewTranslation","Sunday [weekday]","",,"",496,"Bazar günü",1
3764,"ViewTranslation","Monday [weekday]","",,"",496,"Birinci gün",1
3765,"ViewTranslation","Tuesday [weekday]","",,"",496,"Ikinci gün",1
3766,"ViewTranslation","Wednesday [weekday]","",,"",496,"Üçüncü gün",1
3767,"ViewTranslation","Thursday [weekday]","",,"",496,"Dördüncü gün",1
3768,"ViewTranslation","Friday [weekday]","",,"",496,"Beşinci gün",1
3769,"ViewTranslation","Saturday [weekday]","",,"",496,"Altıncı gün",1
3770,"ViewTranslation","Sun [abbreviated weekday]","",,"",496,"Baz",1
3771,"ViewTranslation","Mon [abbreviated weekday]","",,"",496,"Bir",1
3772,"ViewTranslation","Tue [abbreviated weekday]","",,"",496,"Iki",1
3773,"ViewTranslation","Wed [abbreviated weekday]","",,"",496,"Üçü",1
3774,"ViewTranslation","Thu [abbreviated weekday]","",,"",496,"Dör",1
3775,"ViewTranslation","Fri [abbreviated weekday]","",,"",496,"Beş",1
3776,"ViewTranslation","Sat [abbreviated weekday]","",,"",496,"Alt",1
3777,"ViewTranslation","January [month]","",,"",496,"Yanvar",1
3778,"ViewTranslation","February [month]","",,"",496,"Fevral",1
3779,"ViewTranslation","March [month]","",,"",496,"Mart",1
3780,"ViewTranslation","April [month]","",,"",496,"Aprel",1
3781,"ViewTranslation","May [month]","",,"",496,"May",1
3782,"ViewTranslation","June [month]","",,"",496,"Iyun",1
3783,"ViewTranslation","July [month]","",,"",496,"Iyul",1
3784,"ViewTranslation","August [month]","",,"",496,"Avqust",1
3785,"ViewTranslation","September [month]","",,"",496,"Sentyabr",1
3786,"ViewTranslation","October [month]","",,"",496,"Oktyabr",1
3787,"ViewTranslation","November [month]","",,"",496,"Noyabr",1
3788,"ViewTranslation","December [month]","",,"",496,"Dekabr",1
3789,"ViewTranslation","Jan [abbreviated month]","",,"",496,"Yan",1
3790,"ViewTranslation","Feb [abbreviated month]","",,"",496,"Fev",1
3791,"ViewTranslation","Mar [abbreviated month]","",,"",496,"Mar",1
3792,"ViewTranslation","Apr [abbreviated month]","",,"",496,"Apr",1
3793,"ViewTranslation","May [abbreviated month]","",,"",496,"May",1
3794,"ViewTranslation","Jun [abbreviated month]","",,"",496,"İyn",1
3795,"ViewTranslation","Jul [abbreviated month]","",,"",496,"İyl",1
3796,"ViewTranslation","Aug [abbreviated month]","",,"",496,"Avq",1
3797,"ViewTranslation","Sep [abbreviated month]","",,"",496,"Sen",1
3798,"ViewTranslation","Oct [abbreviated month]","",,"",496,"Okt",1
3799,"ViewTranslation","Nov [abbreviated month]","",,"",496,"Noy",1
3800,"ViewTranslation","Dec [abbreviated month]","",,"",496,"Dek",1
3801,"ViewTranslation","Sunday [weekday]","",,"",614,"Нядзеля",1
3802,"ViewTranslation","Monday [weekday]","",,"",614,"Панядзелак",1
3803,"ViewTranslation","Tuesday [weekday]","",,"",614,"Аўторак",1
3804,"ViewTranslation","Wednesday [weekday]","",,"",614,"Серада",1
3805,"ViewTranslation","Thursday [weekday]","",,"",614,"Чацвер",1
3806,"ViewTranslation","Friday [weekday]","",,"",614,"Пятніца",1
3807,"ViewTranslation","Saturday [weekday]","",,"",614,"Субота",1
3808,"ViewTranslation","Sun [abbreviated weekday]","",,"",614,"Няд",1
3809,"ViewTranslation","Mon [abbreviated weekday]","",,"",614,"Пан",1
3810,"ViewTranslation","Tue [abbreviated weekday]","",,"",614,"Аўт",1
3811,"ViewTranslation","Wed [abbreviated weekday]","",,"",614,"Срд",1
3812,"ViewTranslation","Thu [abbreviated weekday]","",,"",614,"Чцв",1
3813,"ViewTranslation","Fri [abbreviated weekday]","",,"",614,"Пят",1
3814,"ViewTranslation","Sat [abbreviated weekday]","",,"",614,"Суб",1
3815,"ViewTranslation","January [month]","",,"",614,"Студзень",1
3816,"ViewTranslation","February [month]","",,"",614,"Люты",1
3817,"ViewTranslation","March [month]","",,"",614,"Сакавік",1
3818,"ViewTranslation","April [month]","",,"",614,"Красавік",1
3819,"ViewTranslation","May [month]","",,"",614,"Травень",1
3820,"ViewTranslation","June [month]","",,"",614,"Чэрвень",1
3821,"ViewTranslation","July [month]","",,"",614,"Ліпень",1
3822,"ViewTranslation","August [month]","",,"",614,"Жнівень",1
3823,"ViewTranslation","September [month]","",,"",614,"Верасень",1
3824,"ViewTranslation","October [month]","",,"",614,"Кастрычнік",1
3825,"ViewTranslation","November [month]","",,"",614,"Лістапад",1
3826,"ViewTranslation","December [month]","",,"",614,"Снежань",1
3827,"ViewTranslation","Jan [abbreviated month]","",,"",614,"Стд",1
3828,"ViewTranslation","Feb [abbreviated month]","",,"",614,"Лют",1
3829,"ViewTranslation","Mar [abbreviated month]","",,"",614,"Сак",1
3830,"ViewTranslation","Apr [abbreviated month]","",,"",614,"Крс",1
3831,"ViewTranslation","May [abbreviated month]","",,"",614,"Тра",1
3832,"ViewTranslation","Jun [abbreviated month]","",,"",614,"Чэр",1
3833,"ViewTranslation","Jul [abbreviated month]","",,"",614,"Ліп",1
3834,"ViewTranslation","Aug [abbreviated month]","",,"",614,"Жнв",1
3835,"ViewTranslation","Sep [abbreviated month]","",,"",614,"Врс",1
3836,"ViewTranslation","Oct [abbreviated month]","",,"",614,"Кст",1
3837,"ViewTranslation","Nov [abbreviated month]","",,"",614,"Ліс",1
3838,"ViewTranslation","Dec [abbreviated month]","",,"",614,"Снж",1
3839,"ViewTranslation","Sunday [weekday]","",,"",1020,"Неделя",1
3840,"ViewTranslation","Monday [weekday]","",,"",1020,"Понеделник",1
3841,"ViewTranslation","Tuesday [weekday]","",,"",1020,"Вторник",1
3842,"ViewTranslation","Wednesday [weekday]","",,"",1020,"Сряда",1
3843,"ViewTranslation","Thursday [weekday]","",,"",1020,"Четвъртък",1
3844,"ViewTranslation","Friday [weekday]","",,"",1020,"Петък",1
3845,"ViewTranslation","Saturday [weekday]","",,"",1020,"Събота",1
3846,"ViewTranslation","Sun [abbreviated weekday]","",,"",1020,"Нд",1
3847,"ViewTranslation","Mon [abbreviated weekday]","",,"",1020,"Пн",1
3848,"ViewTranslation","Tue [abbreviated weekday]","",,"",1020,"Вт",1
3849,"ViewTranslation","Wed [abbreviated weekday]","",,"",1020,"Ср",1
3850,"ViewTranslation","Thu [abbreviated weekday]","",,"",1020,"Чт",1
3851,"ViewTranslation","Fri [abbreviated weekday]","",,"",1020,"Пт",1
3852,"ViewTranslation","Sat [abbreviated weekday]","",,"",1020,"Сб",1
3853,"ViewTranslation","January [month]","",,"",1020,"Януари",1
3854,"ViewTranslation","February [month]","",,"",1020,"Февруари",1
3855,"ViewTranslation","March [month]","",,"",1020,"Март",1
3856,"ViewTranslation","April [month]","",,"",1020,"Април",1
3857,"ViewTranslation","May [month]","",,"",1020,"Май",1
3858,"ViewTranslation","June [month]","",,"",1020,"Юни",1
3859,"ViewTranslation","July [month]","",,"",1020,"Юли",1
3860,"ViewTranslation","August [month]","",,"",1020,"Август",1
3861,"ViewTranslation","September [month]","",,"",1020,"Септември",1
3862,"ViewTranslation","October [month]","",,"",1020,"Октомври",1
3863,"ViewTranslation","November [month]","",,"",1020,"Ноември",1
3864,"ViewTranslation","December [month]","",,"",1020,"Декември",1
3865,"ViewTranslation","Jan [abbreviated month]","",,"",1020,"Яну",1
3866,"ViewTranslation","Feb [abbreviated month]","",,"",1020,"Фев",1
3867,"ViewTranslation","Mar [abbreviated month]","",,"",1020,"Мар",1
3868,"ViewTranslation","Apr [abbreviated month]","",,"",1020,"Апр",1
3869,"ViewTranslation","May [abbreviated month]","",,"",1020,"Май",1
3870,"ViewTranslation","Jun [abbreviated month]","",,"",1020,"Юни",1
3871,"ViewTranslation","Jul [abbreviated month]","",,"",1020,"Юли",1
3872,"ViewTranslation","Aug [abbreviated month]","",,"",1020,"Авг",1
3873,"ViewTranslation","Sep [abbreviated month]","",,"",1020,"Сеп",1
3874,"ViewTranslation","Oct [abbreviated month]","",,"",1020,"Окт",1
3875,"ViewTranslation","Nov [abbreviated month]","",,"",1020,"Ное",1
3876,"ViewTranslation","Dec [abbreviated month]","",,"",1020,"Дек",1
3877,"ViewTranslation","Sunday [weekday]","",,"",616,"রবিবার",1
3878,"ViewTranslation","Monday [weekday]","",,"",616,"সোমবার",1
3879,"ViewTranslation","Tuesday [weekday]","",,"",616,"মঙগলবার",1
3880,"ViewTranslation","Wednesday [weekday]","",,"",616,"বুধবার",1
3881,"ViewTranslation","Thursday [weekday]","",,"",616,"বৃহস্পতিবার",1
3882,"ViewTranslation","Friday [weekday]","",,"",616,"শুক্রবার",1
3883,"ViewTranslation","Saturday [weekday]","",,"",616,"শনিবার",1
3884,"ViewTranslation","Sun [abbreviated weekday]","",,"",616,"রবি",1
3885,"ViewTranslation","Mon [abbreviated weekday]","",,"",616,"সোম",1
3886,"ViewTranslation","Tue [abbreviated weekday]","",,"",616,"মঙগল",1
3887,"ViewTranslation","Wed [abbreviated weekday]","",,"",616,"বুধ",1
3888,"ViewTranslation","Thu [abbreviated weekday]","",,"",616,"বৃহস্পতি",1
3889,"ViewTranslation","Fri [abbreviated weekday]","",,"",616,"শুক্র",1
3890,"ViewTranslation","Sat [abbreviated weekday]","",,"",616,"শনি",1
3891,"ViewTranslation","January [month]","",,"",616,"জানুয়ারী",1
3892,"ViewTranslation","February [month]","",,"",616,"ফেব্রুয়ারী",1
3893,"ViewTranslation","March [month]","",,"",616,"মার্চ",1
3894,"ViewTranslation","April [month]","",,"",616,"এপ্রিল",1
3895,"ViewTranslation","May [month]","",,"",616,"মে",1
3896,"ViewTranslation","June [month]","",,"",616,"জুন",1
3897,"ViewTranslation","July [month]","",,"",616,"জুলাই",1
3898,"ViewTranslation","August [month]","",,"",616,"আগস্ট",1
3899,"ViewTranslation","September [month]","",,"",616,"সেপ্টেম্বার",1
3900,"ViewTranslation","October [month]","",,"",616,"অক্টোবার",1
3901,"ViewTranslation","November [month]","",,"",616,"নভেম্বার",1
3902,"ViewTranslation","December [month]","",,"",616,"ডিসেম্বার",1
3903,"ViewTranslation","Jan [abbreviated month]","",,"",616,"জান",1
3904,"ViewTranslation","Feb [abbreviated month]","",,"",616,"ফেব",1
3905,"ViewTranslation","Mar [abbreviated month]","",,"",616,"মার",1
3906,"ViewTranslation","Apr [abbreviated month]","",,"",616,"এপ্র",1
3907,"ViewTranslation","May [abbreviated month]","",,"",616,"মে",1
3908,"ViewTranslation","Jun [abbreviated month]","",,"",616,"জুন",1
3909,"ViewTranslation","Jul [abbreviated month]","",,"",616,"জুল",1
3910,"ViewTranslation","Aug [abbreviated month]","",,"",616,"আগ",1
3911,"ViewTranslation","Sep [abbreviated month]","",,"",616,"সেপ",1
3912,"ViewTranslation","Oct [abbreviated month]","",,"",616,"অক্টোবর",1
3913,"ViewTranslation","Nov [abbreviated month]","",,"",616,"নভেম্বর",1
3914,"ViewTranslation","Dec [abbreviated month]","",,"",616,"ডিসেম্বর",1
3915,"ViewTranslation","Sunday [weekday]","",,"",936,"Sul",1
3916,"ViewTranslation","Monday [weekday]","",,"",936,"Lun",1
3917,"ViewTranslation","Tuesday [weekday]","",,"",936,"Meurzh",1
3918,"ViewTranslation","Wednesday [weekday]","",,"",936,"Merc'her",1
3919,"ViewTranslation","Thursday [weekday]","",,"",936,"Yaou",1
3920,"ViewTranslation","Friday [weekday]","",,"",936,"Gwener",1
3921,"ViewTranslation","Saturday [weekday]","",,"",936,"Sadorn",1
3922,"ViewTranslation","Sun [abbreviated weekday]","",,"",936,"Sul",1
3923,"ViewTranslation","Mon [abbreviated weekday]","",,"",936,"Lun",1
3924,"ViewTranslation","Tue [abbreviated weekday]","",,"",936,"Meu",1
3925,"ViewTranslation","Wed [abbreviated weekday]","",,"",936,"Mer",1
3926,"ViewTranslation","Thu [abbreviated weekday]","",,"",936,"Yao",1
3927,"ViewTranslation","Fri [abbreviated weekday]","",,"",936,"Gwe",1
3928,"ViewTranslation","Sat [abbreviated weekday]","",,"",936,"Sad",1
3929,"ViewTranslation","January [month]","",,"",936,"Genver",1
3930,"ViewTranslation","February [month]","",,"",936,"C'hwevrer",1
3931,"ViewTranslation","March [month]","",,"",936,"Meurzh",1
3932,"ViewTranslation","April [month]","",,"",936,"Ebrel",1
3933,"ViewTranslation","May [month]","",,"",936,"Mae",1
3934,"ViewTranslation","June [month]","",,"",936,"Mezheven",1
3935,"ViewTranslation","July [month]","",,"",936,"Gouere",1
3936,"ViewTranslation","August [month]","",,"",936,"Eost",1
3937,"ViewTranslation","September [month]","",,"",936,"Gwengolo",1
3938,"ViewTranslation","October [month]","",,"",936,"Here",1
3939,"ViewTranslation","November [month]","",,"",936,"Du",1
3940,"ViewTranslation","December [month]","",,"",936,"Kerzu",1
3941,"ViewTranslation","Jan [abbreviated month]","",,"",936,"Gen ",1
3942,"ViewTranslation","Feb [abbreviated month]","",,"",936,"C'hw",1
3943,"ViewTranslation","Mar [abbreviated month]","",,"",936,"Meu ",1
3944,"ViewTranslation","Apr [abbreviated month]","",,"",936,"Ebr ",1
3945,"ViewTranslation","May [abbreviated month]","",,"",936,"Mae ",1
3946,"ViewTranslation","Jun [abbreviated month]","",,"",936,"Eve ",1
3947,"ViewTranslation","Jul [abbreviated month]","",,"",936,"Gou ",1
3948,"ViewTranslation","Aug [abbreviated month]","",,"",936,"Eos ",1
3949,"ViewTranslation","Sep [abbreviated month]","",,"",936,"Gwe ",1
3950,"ViewTranslation","Oct [abbreviated month]","",,"",936,"Her ",1
3951,"ViewTranslation","Nov [abbreviated month]","",,"",936,"Du ",1
3952,"ViewTranslation","Dec [abbreviated month]","",,"",936,"Ker ",1
3953,"ViewTranslation","Sunday [weekday]","",,"",875,"Nedjelja",1
3954,"ViewTranslation","Monday [weekday]","",,"",875,"Ponedjeljak",1
3955,"ViewTranslation","Tuesday [weekday]","",,"",875,"Utorak",1
3956,"ViewTranslation","Wednesday [weekday]","",,"",875,"Srijeda",1
3957,"ViewTranslation","Thursday [weekday]","",,"",875,"Četvrtak",1
3958,"ViewTranslation","Friday [weekday]","",,"",875,"Petak",1
3959,"ViewTranslation","Saturday [weekday]","",,"",875,"Subota",1
3960,"ViewTranslation","Sun [abbreviated weekday]","",,"",875,"Ned",1
3961,"ViewTranslation","Mon [abbreviated weekday]","",,"",875,"Pon",1
3962,"ViewTranslation","Tue [abbreviated weekday]","",,"",875,"Uto",1
3963,"ViewTranslation","Wed [abbreviated weekday]","",,"",875,"Sri",1
3964,"ViewTranslation","Thu [abbreviated weekday]","",,"",875,"Čet",1
3965,"ViewTranslation","Fri [abbreviated weekday]","",,"",875,"Pet",1
3966,"ViewTranslation","Sat [abbreviated weekday]","",,"",875,"Sub",1
3967,"ViewTranslation","January [month]","",,"",875,"Januar",1
3968,"ViewTranslation","February [month]","",,"",875,"Februar",1
3969,"ViewTranslation","March [month]","",,"",875,"Mart",1
3970,"ViewTranslation","April [month]","",,"",875,"April",1
3971,"ViewTranslation","May [month]","",,"",875,"Maj",1
3972,"ViewTranslation","June [month]","",,"",875,"Juni",1
3973,"ViewTranslation","July [month]","",,"",875,"Juli",1
3974,"ViewTranslation","August [month]","",,"",875,"August",1
3975,"ViewTranslation","September [month]","",,"",875,"Septembar",1
3976,"ViewTranslation","October [month]","",,"",875,"Oktobar",1
3977,"ViewTranslation","November [month]","",,"",875,"Novembar",1
3978,"ViewTranslation","December [month]","",,"",875,"Decembar",1
3979,"ViewTranslation","Jan [abbreviated month]","",,"",875,"Jan",1
3980,"ViewTranslation","Feb [abbreviated month]","",,"",875,"Feb",1
3981,"ViewTranslation","Mar [abbreviated month]","",,"",875,"Mar",1
3982,"ViewTranslation","Apr [abbreviated month]","",,"",875,"Apr",1
3983,"ViewTranslation","May [abbreviated month]","",,"",875,"Maj",1
3984,"ViewTranslation","Jun [abbreviated month]","",,"",875,"Jun",1
3985,"ViewTranslation","Jul [abbreviated month]","",,"",875,"Jul",1
3986,"ViewTranslation","Aug [abbreviated month]","",,"",875,"Aug",1
3987,"ViewTranslation","Sep [abbreviated month]","",,"",875,"Sep",1
3988,"ViewTranslation","Oct [abbreviated month]","",,"",875,"Okt",1
3989,"ViewTranslation","Nov [abbreviated month]","",,"",875,"Nov",1
3990,"ViewTranslation","Dec [abbreviated month]","",,"",875,"Dec",1
3991,"ViewTranslation","Sunday [weekday]","",,"",1122,"ሰንበር ቅዳዅ",1
3992,"ViewTranslation","Monday [weekday]","",,"",1122,"ሰኑ",1
3993,"ViewTranslation","Tuesday [weekday]","",,"",1122,"ሰሊጝ",1
3994,"ViewTranslation","Wednesday [weekday]","",,"",1122,"ለጓ ወሪ ለብዋ",1
3995,"ViewTranslation","Thursday [weekday]","",,"",1122,"ኣምድ",1
3996,"ViewTranslation","Friday [weekday]","",,"",1122,"ኣርብ",1
3997,"ViewTranslation","Saturday [weekday]","",,"",1122,"ሰንበር ሽጓዅ",1
3998,"ViewTranslation","Sun [abbreviated weekday]","",,"",1122,"ሰ/ቅ",1
3999,"ViewTranslation","Mon [abbreviated weekday]","",,"",1122,"ሰኑ",1
4000,"ViewTranslation","Tue [abbreviated weekday]","",,"",1122,"ሰሊጝ",1
4001,"ViewTranslation","Wed [abbreviated weekday]","",,"",1122,"ለጓ",1
4002,"ViewTranslation","Thu [abbreviated weekday]","",,"",1122,"ኣምድ",1
4003,"ViewTranslation","Fri [abbreviated weekday]","",,"",1122,"ኣርብ",1
4004,"ViewTranslation","Sat [abbreviated weekday]","",,"",1122,"ሰ/ሽ",1
4005,"ViewTranslation","January [month]","",,"",1122,"ልደትሪ",1
4006,"ViewTranslation","February [month]","",,"",1122,"ካብኽብቲ",1
4007,"ViewTranslation","March [month]","",,"",1122,"ክብላ",1
4008,"ViewTranslation","April [month]","",,"",1122,"ፋጅኺሪ",1
4009,"ViewTranslation","May [month]","",,"",1122,"ክቢቅሪ",1
4010,"ViewTranslation","June [month]","",,"",1122,"ምኪኤል ትጓ̅ኒሪ",1
4011,"ViewTranslation","July [month]","",,"",1122,"ኰርኩ",1
4012,"ViewTranslation","August [month]","",,"",1122,"ማርያም ትሪ",1
4013,"ViewTranslation","September [month]","",,"",1122,"ያኸኒ መሳቅለሪ",1
4014,"ViewTranslation","October [month]","",,"",1122,"መተሉ",1
4015,"ViewTranslation","November [month]","",,"",1122,"ምኪኤል መሽወሪ",1
4016,"ViewTranslation","December [month]","",,"",1122,"ተሕሳስሪ",1
4017,"ViewTranslation","Jan [abbreviated month]","",,"",1122,"ልደት",1
4018,"ViewTranslation","Feb [abbreviated month]","",,"",1122,"ካብኽ",1
4019,"ViewTranslation","Mar [abbreviated month]","",,"",1122,"ክብላ",1
4020,"ViewTranslation","Apr [abbreviated month]","",,"",1122,"ፋጅኺ",1
4021,"ViewTranslation","May [abbreviated month]","",,"",1122,"ክቢቅ",1
4022,"ViewTranslation","Jun [abbreviated month]","",,"",1122,"ም/ት",1
4023,"ViewTranslation","Jul [abbreviated month]","",,"",1122,"ኰር",1
4024,"ViewTranslation","Aug [abbreviated month]","",,"",1122,"ማርያ",1
4025,"ViewTranslation","Sep [abbreviated month]","",,"",1122,"ያኸኒ",1
4026,"ViewTranslation","Oct [abbreviated month]","",,"",1122,"መተሉ",1
4027,"ViewTranslation","Nov [abbreviated month]","",,"",1122,"ም/ም",1
4028,"ViewTranslation","Dec [abbreviated month]","",,"",1122,"ተሕሳ",1
4029,"ViewTranslation","Sunday [weekday]","",,"",1177,"Diumenge",1
4030,"ViewTranslation","Monday [weekday]","",,"",1177,"Dilluns",1
4031,"ViewTranslation","Tuesday [weekday]","",,"",1177,"Dimarts",1
4032,"ViewTranslation","Wednesday [weekday]","",,"",1177,"Dimecres",1
4033,"ViewTranslation","Thursday [weekday]","",,"",1177,"Dijous",1
4034,"ViewTranslation","Friday [weekday]","",,"",1177,"Divendres",1
4035,"ViewTranslation","Saturday [weekday]","",,"",1177,"Dissabte",1
4036,"ViewTranslation","Sun [abbreviated weekday]","",,"",1177,"Dg",1
4037,"ViewTranslation","Mon [abbreviated weekday]","",,"",1177,"Dl",1
4038,"ViewTranslation","Tue [abbreviated weekday]","",,"",1177,"Dt",1
4039,"ViewTranslation","Wed [abbreviated weekday]","",,"",1177,"Dc",1
4040,"ViewTranslation","Thu [abbreviated weekday]","",,"",1177,"Dj",1
4041,"ViewTranslation","Fri [abbreviated weekday]","",,"",1177,"Dv",1
4042,"ViewTranslation","Sat [abbreviated weekday]","",,"",1177,"Ds",1
4043,"ViewTranslation","January [month]","",,"",1177,"Gener",1
4044,"ViewTranslation","February [month]","",,"",1177,"Febrer",1
4045,"ViewTranslation","March [month]","",,"",1177,"Març",1
4046,"ViewTranslation","April [month]","",,"",1177,"Abril",1
4047,"ViewTranslation","May [month]","",,"",1177,"Maig",1
4048,"ViewTranslation","June [month]","",,"",1177,"Juny",1
4049,"ViewTranslation","July [month]","",,"",1177,"Juliol",1
4050,"ViewTranslation","August [month]","",,"",1177,"Agost",1
4051,"ViewTranslation","September [month]","",,"",1177,"Setembre",1
4052,"ViewTranslation","October [month]","",,"",1177,"Octubre",1
4053,"ViewTranslation","November [month]","",,"",1177,"Novembre",1
4054,"ViewTranslation","December [month]","",,"",1177,"Desembre",1
4055,"ViewTranslation","Jan [abbreviated month]","",,"",1177,"Gen",1
4056,"ViewTranslation","Feb [abbreviated month]","",,"",1177,"Feb",1
4057,"ViewTranslation","Mar [abbreviated month]","",,"",1177,"Mar",1
4058,"ViewTranslation","Apr [abbreviated month]","",,"",1177,"Abr",1
4059,"ViewTranslation","May [abbreviated month]","",,"",1177,"Mai",1
4060,"ViewTranslation","Jun [abbreviated month]","",,"",1177,"Jun",1
4061,"ViewTranslation","Jul [abbreviated month]","",,"",1177,"Jul",1
4062,"ViewTranslation","Aug [abbreviated month]","",,"",1177,"Ago",1
4063,"ViewTranslation","Sep [abbreviated month]","",,"",1177,"Set",1
4064,"ViewTranslation","Oct [abbreviated month]","",,"",1177,"Oct",1
4065,"ViewTranslation","Nov [abbreviated month]","",,"",1177,"Nov",1
4066,"ViewTranslation","Dec [abbreviated month]","",,"",1177,"Des",1
4067,"ViewTranslation","Sunday [weekday]","",,"",1233,"Neděle",1
4068,"ViewTranslation","Monday [weekday]","",,"",1233,"Pondělí",1
4069,"ViewTranslation","Tuesday [weekday]","",,"",1233,"Úterý",1
4070,"ViewTranslation","Wednesday [weekday]","",,"",1233,"Středa",1
4071,"ViewTranslation","Thursday [weekday]","",,"",1233,"Čtvrtek",1
4072,"ViewTranslation","Friday [weekday]","",,"",1233,"Pátek",1
4073,"ViewTranslation","Saturday [weekday]","",,"",1233,"Sobota",1
4074,"ViewTranslation","Sun [abbreviated weekday]","",,"",1233,"Ne",1
4075,"ViewTranslation","Mon [abbreviated weekday]","",,"",1233,"Po",1
4076,"ViewTranslation","Tue [abbreviated weekday]","",,"",1233,"Út",1
4077,"ViewTranslation","Wed [abbreviated weekday]","",,"",1233,"St",1
4078,"ViewTranslation","Thu [abbreviated weekday]","",,"",1233,"Čt",1
4079,"ViewTranslation","Fri [abbreviated weekday]","",,"",1233,"Pá",1
4080,"ViewTranslation","Sat [abbreviated weekday]","",,"",1233,"So",1
4081,"ViewTranslation","January [month]","",,"",1233,"Leden",1
4082,"ViewTranslation","February [month]","",,"",1233,"Únor",1
4083,"ViewTranslation","March [month]","",,"",1233,"Březen",1
4084,"ViewTranslation","April [month]","",,"",1233,"Duben",1
4085,"ViewTranslation","May [month]","",,"",1233,"Květen",1
4086,"ViewTranslation","June [month]","",,"",1233,"Červen",1
4087,"ViewTranslation","July [month]","",,"",1233,"Červenec",1
4088,"ViewTranslation","August [month]","",,"",1233,"Srpen",1
4089,"ViewTranslation","September [month]","",,"",1233,"Září",1
4090,"ViewTranslation","October [month]","",,"",1233,"Říjen",1
4091,"ViewTranslation","November [month]","",,"",1233,"Listopad",1
4092,"ViewTranslation","December [month]","",,"",1233,"Prosinec",1
4093,"ViewTranslation","Jan [abbreviated month]","",,"",1233,"Led",1
4094,"ViewTranslation","Feb [abbreviated month]","",,"",1233,"Úno",1
4095,"ViewTranslation","Mar [abbreviated month]","",,"",1233,"Bře",1
4096,"ViewTranslation","Apr [abbreviated month]","",,"",1233,"Dub",1
4097,"ViewTranslation","May [abbreviated month]","",,"",1233,"Kvě",1
4098,"ViewTranslation","Jun [abbreviated month]","",,"",1233,"Čen",1
4099,"ViewTranslation","Jul [abbreviated month]","",,"",1233,"Čec",1
4100,"ViewTranslation","Aug [abbreviated month]","",,"",1233,"Srp",1
4101,"ViewTranslation","Sep [abbreviated month]","",,"",1233,"Zář",1
4102,"ViewTranslation","Oct [abbreviated month]","",,"",1233,"Říj",1
4103,"ViewTranslation","Nov [abbreviated month]","",,"",1233,"Lis",1
4104,"ViewTranslation","Dec [abbreviated month]","",,"",1233,"Pro",1
4105,"ViewTranslation","Sunday [weekday]","",,"",1481,"Sul",1
4106,"ViewTranslation","Monday [weekday]","",,"",1481,"Llun",1
4107,"ViewTranslation","Tuesday [weekday]","",,"",1481,"Mawrth",1
4108,"ViewTranslation","Wednesday [weekday]","",,"",1481,"Mercher",1
4109,"ViewTranslation","Thursday [weekday]","",,"",1481,"Iau",1
4110,"ViewTranslation","Friday [weekday]","",,"",1481,"Gwener",1
4111,"ViewTranslation","Saturday [weekday]","",,"",1481,"Sadwrn",1
4112,"ViewTranslation","Sun [abbreviated weekday]","",,"",1481,"Sul",1
4113,"ViewTranslation","Mon [abbreviated weekday]","",,"",1481,"Llu",1
4114,"ViewTranslation","Tue [abbreviated weekday]","",,"",1481,"Maw",1
4115,"ViewTranslation","Wed [abbreviated weekday]","",,"",1481,"Mer",1
4116,"ViewTranslation","Thu [abbreviated weekday]","",,"",1481,"Iau",1
4117,"ViewTranslation","Fri [abbreviated weekday]","",,"",1481,"Gwe",1
4118,"ViewTranslation","Sat [abbreviated weekday]","",,"",1481,"Sad",1
4119,"ViewTranslation","January [month]","",,"",1481,"Ionawr",1
4120,"ViewTranslation","February [month]","",,"",1481,"Chwefror",1
4121,"ViewTranslation","March [month]","",,"",1481,"Mawrth",1
4122,"ViewTranslation","April [month]","",,"",1481,"Ebrill",1
4123,"ViewTranslation","May [month]","",,"",1481,"Mai",1
4124,"ViewTranslation","June [month]","",,"",1481,"Mehefin",1
4125,"ViewTranslation","July [month]","",,"",1481,"Gorffennaf",1
4126,"ViewTranslation","August [month]","",,"",1481,"Awst",1
4127,"ViewTranslation","September [month]","",,"",1481,"Medi",1
4128,"ViewTranslation","October [month]","",,"",1481,"Hydref",1
4129,"ViewTranslation","November [month]","",,"",1481,"Tachwedd",1
4130,"ViewTranslation","December [month]","",,"",1481,"Rhagfyr",1
4131,"ViewTranslation","Jan [abbreviated month]","",,"",1481,"Ion",1
4132,"ViewTranslation","Feb [abbreviated month]","",,"",1481,"Chw",1
4133,"ViewTranslation","Mar [abbreviated month]","",,"",1481,"Maw",1
4134,"ViewTranslation","Apr [abbreviated month]","",,"",1481,"Ebr",1
4135,"ViewTranslation","May [abbreviated month]","",,"",1481,"Mai",1
4136,"ViewTranslation","Jun [abbreviated month]","",,"",1481,"Meh",1
4137,"ViewTranslation","Jul [abbreviated month]","",,"",1481,"Gor",1
4138,"ViewTranslation","Aug [abbreviated month]","",,"",1481,"Aws",1
4139,"ViewTranslation","Sep [abbreviated month]","",,"",1481,"Med",1
4140,"ViewTranslation","Oct [abbreviated month]","",,"",1481,"Hyd",1
4141,"ViewTranslation","Nov [abbreviated month]","",,"",1481,"Tach",1
4142,"ViewTranslation","Dec [abbreviated month]","",,"",1481,"Rha",1
4143,"ViewTranslation","Sunday [weekday]","",,"",1499,"Søndag",1
4144,"ViewTranslation","Monday [weekday]","",,"",1499,"Mandag",1
4145,"ViewTranslation","Tuesday [weekday]","",,"",1499,"Tirsdag",1
4146,"ViewTranslation","Wednesday [weekday]","",,"",1499,"Onsdag",1
4147,"ViewTranslation","Thursday [weekday]","",,"",1499,"Torsdag",1
4148,"ViewTranslation","Friday [weekday]","",,"",1499,"Fredag",1
4149,"ViewTranslation","Saturday [weekday]","",,"",1499,"Lørdag",1
4150,"ViewTranslation","Sun [abbreviated weekday]","",,"",1499,"Søn",1
4151,"ViewTranslation","Mon [abbreviated weekday]","",,"",1499,"Man",1
4152,"ViewTranslation","Tue [abbreviated weekday]","",,"",1499,"Tir",1
4153,"ViewTranslation","Wed [abbreviated weekday]","",,"",1499,"Ons",1
4154,"ViewTranslation","Thu [abbreviated weekday]","",,"",1499,"Tor",1
4155,"ViewTranslation","Fri [abbreviated weekday]","",,"",1499,"Fre",1
4156,"ViewTranslation","Sat [abbreviated weekday]","",,"",1499,"Lør",1
4157,"ViewTranslation","January [month]","",,"",1499,"Januar",1
4158,"ViewTranslation","February [month]","",,"",1499,"Februar",1
4159,"ViewTranslation","March [month]","",,"",1499,"Marts",1
4160,"ViewTranslation","April [month]","",,"",1499,"April",1
4161,"ViewTranslation","May [month]","",,"",1499,"Maj",1
4162,"ViewTranslation","June [month]","",,"",1499,"Juni",1
4163,"ViewTranslation","July [month]","",,"",1499,"Juli",1
4164,"ViewTranslation","August [month]","",,"",1499,"August",1
4165,"ViewTranslation","September [month]","",,"",1499,"September",1
4166,"ViewTranslation","October [month]","",,"",1499,"Oktober",1
4167,"ViewTranslation","November [month]","",,"",1499,"November",1
4168,"ViewTranslation","December [month]","",,"",1499,"December",1
4169,"ViewTranslation","Jan [abbreviated month]","",,"",1499,"Jan",1
4170,"ViewTranslation","Feb [abbreviated month]","",,"",1499,"Feb",1
4171,"ViewTranslation","Mar [abbreviated month]","",,"",1499,"Mar",1
4172,"ViewTranslation","Apr [abbreviated month]","",,"",1499,"Apr",1
4173,"ViewTranslation","May [abbreviated month]","",,"",1499,"Maj",1
4174,"ViewTranslation","Jun [abbreviated month]","",,"",1499,"Jun",1
4175,"ViewTranslation","Jul [abbreviated month]","",,"",1499,"Jul",1
4176,"ViewTranslation","Aug [abbreviated month]","",,"",1499,"Aug",1
4177,"ViewTranslation","Sep [abbreviated month]","",,"",1499,"Sep",1
4178,"ViewTranslation","Oct [abbreviated month]","",,"",1499,"Okt",1
4179,"ViewTranslation","Nov [abbreviated month]","",,"",1499,"Nov",1
4180,"ViewTranslation","Dec [abbreviated month]","",,"",1499,"Dec",1
4181,"ViewTranslation","Sunday [weekday]","",,"",1793,"Κυριακή",1
4182,"ViewTranslation","Monday [weekday]","",,"",1793,"Δευτέρα",1
4183,"ViewTranslation","Tuesday [weekday]","",,"",1793,"Τρίτη",1
4184,"ViewTranslation","Wednesday [weekday]","",,"",1793,"Τετάρτη",1
4185,"ViewTranslation","Thursday [weekday]","",,"",1793,"Πέμπτη",1
4186,"ViewTranslation","Friday [weekday]","",,"",1793,"Παρασκευή",1
4187,"ViewTranslation","Saturday [weekday]","",,"",1793,"Σάββατο",1
4188,"ViewTranslation","Sun [abbreviated weekday]","",,"",1793,"Κυρ",1
4189,"ViewTranslation","Mon [abbreviated weekday]","",,"",1793,"Δευ",1
4190,"ViewTranslation","Tue [abbreviated weekday]","",,"",1793,"Τρι",1
4191,"ViewTranslation","Wed [abbreviated weekday]","",,"",1793,"Τετ",1
4192,"ViewTranslation","Thu [abbreviated weekday]","",,"",1793,"Πεμ",1
4193,"ViewTranslation","Fri [abbreviated weekday]","",,"",1793,"Παρ",1
4194,"ViewTranslation","Sat [abbreviated weekday]","",,"",1793,"Σαβ",1
4195,"ViewTranslation","January [month]","",,"",1793,"Ιανουάριος",1
4196,"ViewTranslation","February [month]","",,"",1793,"Φεβρουάριος",1
4197,"ViewTranslation","March [month]","",,"",1793,"Μάρτιος",1
4198,"ViewTranslation","April [month]","",,"",1793,"Απρίλιος",1
4199,"ViewTranslation","May [month]","",,"",1793,"Μάιος",1
4200,"ViewTranslation","June [month]","",,"",1793,"Ιούνιος",1
4201,"ViewTranslation","July [month]","",,"",1793,"Ιούλιος",1
4202,"ViewTranslation","August [month]","",,"",1793,"Αύγουστος",1
4203,"ViewTranslation","September [month]","",,"",1793,"Σεπτέμβριος",1
4204,"ViewTranslation","October [month]","",,"",1793,"Οκτώβριος",1
4205,"ViewTranslation","November [month]","",,"",1793,"Νοέμβριος",1
4206,"ViewTranslation","December [month]","",,"",1793,"Δεκέμβριος",1
4207,"ViewTranslation","Jan [abbreviated month]","",,"",1793,"Ιαν",1
4208,"ViewTranslation","Feb [abbreviated month]","",,"",1793,"Φεβ",1
4209,"ViewTranslation","Mar [abbreviated month]","",,"",1793,"Μάρ",1
4210,"ViewTranslation","Apr [abbreviated month]","",,"",1793,"Απρ",1
4211,"ViewTranslation","May [abbreviated month]","",,"",1793,"Μάι",1
4212,"ViewTranslation","Jun [abbreviated month]","",,"",1793,"Ιούν",1
4213,"ViewTranslation","Jul [abbreviated month]","",,"",1793,"Ιούλ",1
4214,"ViewTranslation","Aug [abbreviated month]","",,"",1793,"Αύγ",1
4215,"ViewTranslation","Sep [abbreviated month]","",,"",1793,"Σεπ",1
4216,"ViewTranslation","Oct [abbreviated month]","",,"",1793,"Οκτ",1
4217,"ViewTranslation","Nov [abbreviated month]","",,"",1793,"Νοέ",1
4218,"ViewTranslation","Dec [abbreviated month]","",,"",1793,"Δεκ",1
4219,"ViewTranslation","Sunday [weekday]","",,"",1819,"Sunday",1
4220,"ViewTranslation","Monday [weekday]","",,"",1819,"Monday",1
4221,"ViewTranslation","Tuesday [weekday]","",,"",1819,"Tuesday",1
4222,"ViewTranslation","Wednesday [weekday]","",,"",1819,"Wednesday",1
4223,"ViewTranslation","Thursday [weekday]","",,"",1819,"Thursday",1
4224,"ViewTranslation","Friday [weekday]","",,"",1819,"Friday",1
4225,"ViewTranslation","Saturday [weekday]","",,"",1819,"Saturday",1
4226,"ViewTranslation","Sun [abbreviated weekday]","",,"",1819,"Sun",1
4227,"ViewTranslation","Mon [abbreviated weekday]","",,"",1819,"Mon",1
4228,"ViewTranslation","Tue [abbreviated weekday]","",,"",1819,"Tue",1
4229,"ViewTranslation","Wed [abbreviated weekday]","",,"",1819,"Wed",1
4230,"ViewTranslation","Thu [abbreviated weekday]","",,"",1819,"Thu",1
4231,"ViewTranslation","Fri [abbreviated weekday]","",,"",1819,"Fri",1
4232,"ViewTranslation","Sat [abbreviated weekday]","",,"",1819,"Sat",1
4233,"ViewTranslation","January [month]","",,"",1819,"January",1
4234,"ViewTranslation","February [month]","",,"",1819,"February",1
4235,"ViewTranslation","March [month]","",,"",1819,"March",1
4236,"ViewTranslation","April [month]","",,"",1819,"April",1
4237,"ViewTranslation","May [month]","",,"",1819,"May",1
4238,"ViewTranslation","June [month]","",,"",1819,"June",1
4239,"ViewTranslation","July [month]","",,"",1819,"July",1
4240,"ViewTranslation","August [month]","",,"",1819,"August",1
4241,"ViewTranslation","September [month]","",,"",1819,"September",1
4242,"ViewTranslation","October [month]","",,"",1819,"October",1
4243,"ViewTranslation","November [month]","",,"",1819,"November",1
4244,"ViewTranslation","December [month]","",,"",1819,"December",1
4245,"ViewTranslation","Jan [abbreviated month]","",,"",1819,"Jan",1
4246,"ViewTranslation","Feb [abbreviated month]","",,"",1819,"Feb",1
4247,"ViewTranslation","Mar [abbreviated month]","",,"",1819,"Mar",1
4248,"ViewTranslation","Apr [abbreviated month]","",,"",1819,"Apr",1
4249,"ViewTranslation","May [abbreviated month]","",,"",1819,"May",1
4250,"ViewTranslation","Jun [abbreviated month]","",,"",1819,"Jun",1
4251,"ViewTranslation","Jul [abbreviated month]","",,"",1819,"Jul",1
4252,"ViewTranslation","Aug [abbreviated month]","",,"",1819,"Aug",1
4253,"ViewTranslation","Sep [abbreviated month]","",,"",1819,"Sep",1
4254,"ViewTranslation","Oct [abbreviated month]","",,"",1819,"Oct",1
4255,"ViewTranslation","Nov [abbreviated month]","",,"",1819,"Nov",1
4256,"ViewTranslation","Dec [abbreviated month]","",,"",1819,"Dec",1
4257,"ViewTranslation","Sunday [weekday]","",,"",5889,"Domingo",1
4258,"ViewTranslation","Monday [weekday]","",,"",5889,"Lunes",1
4259,"ViewTranslation","Tuesday [weekday]","",,"",5889,"Martes",1
4260,"ViewTranslation","Wednesday [weekday]","",,"",5889,"Miércoles",1
4261,"ViewTranslation","Thursday [weekday]","",,"",5889,"Jueves",1
4262,"ViewTranslation","Friday [weekday]","",,"",5889,"Viernes",1
4263,"ViewTranslation","Saturday [weekday]","",,"",5889,"Sábado",1
4264,"ViewTranslation","Sun [abbreviated weekday]","",,"",5889,"Dom",1
4265,"ViewTranslation","Mon [abbreviated weekday]","",,"",5889,"Lun",1
4266,"ViewTranslation","Tue [abbreviated weekday]","",,"",5889,"Mar",1
4267,"ViewTranslation","Wed [abbreviated weekday]","",,"",5889,"Mié",1
4268,"ViewTranslation","Thu [abbreviated weekday]","",,"",5889,"Jue",1
4269,"ViewTranslation","Fri [abbreviated weekday]","",,"",5889,"Vie",1
4270,"ViewTranslation","Sat [abbreviated weekday]","",,"",5889,"Sáb",1
4271,"ViewTranslation","January [month]","",,"",5889,"Enero",1
4272,"ViewTranslation","February [month]","",,"",5889,"Febrero",1
4273,"ViewTranslation","March [month]","",,"",5889,"Marzo",1
4274,"ViewTranslation","April [month]","",,"",5889,"Abril",1
4275,"ViewTranslation","May [month]","",,"",5889,"Mayo",1
4276,"ViewTranslation","June [month]","",,"",5889,"Junio",1
4277,"ViewTranslation","July [month]","",,"",5889,"Julio",1
4278,"ViewTranslation","August [month]","",,"",5889,"Agosto",1
4279,"ViewTranslation","September [month]","",,"",5889,"Septiembre",1
4280,"ViewTranslation","October [month]","",,"",5889,"Octubre",1
4281,"ViewTranslation","November [month]","",,"",5889,"Noviembre",1
4282,"ViewTranslation","December [month]","",,"",5889,"Diciembre",1
4283,"ViewTranslation","Jan [abbreviated month]","",,"",5889,"Ene",1
4284,"ViewTranslation","Feb [abbreviated month]","",,"",5889,"Feb",1
4285,"ViewTranslation","Mar [abbreviated month]","",,"",5889,"Mar",1
4286,"ViewTranslation","Apr [abbreviated month]","",,"",5889,"Abr",1
4287,"ViewTranslation","May [abbreviated month]","",,"",5889,"May",1
4288,"ViewTranslation","Jun [abbreviated month]","",,"",5889,"Jun",1
4289,"ViewTranslation","Jul [abbreviated month]","",,"",5889,"Jul",1
4290,"ViewTranslation","Aug [abbreviated month]","",,"",5889,"Ago",1
4291,"ViewTranslation","Sep [abbreviated month]","",,"",5889,"Sep",1
4292,"ViewTranslation","Oct [abbreviated month]","",,"",5889,"Oct",1
4293,"ViewTranslation","Nov [abbreviated month]","",,"",5889,"Nov",1
4294,"ViewTranslation","Dec [abbreviated month]","",,"",5889,"Dic",1
4295,"ViewTranslation","Sunday [weekday]","",,"",1851,"Pühapäev",1
4296,"ViewTranslation","Monday [weekday]","",,"",1851,"Esmaspäev",1
4297,"ViewTranslation","Tuesday [weekday]","",,"",1851,"Teisipäev",1
4298,"ViewTranslation","Wednesday [weekday]","",,"",1851,"Kolmapäev",1
4299,"ViewTranslation","Thursday [weekday]","",,"",1851,"Neljapäev",1
4300,"ViewTranslation","Friday [weekday]","",,"",1851,"Reede",1
4301,"ViewTranslation","Saturday [weekday]","",,"",1851,"Laupäev",1
4302,"ViewTranslation","Sun [abbreviated weekday]","",,"",1851,"P",1
4303,"ViewTranslation","Mon [abbreviated weekday]","",,"",1851,"E",1
4304,"ViewTranslation","Tue [abbreviated weekday]","",,"",1851,"T",1
4305,"ViewTranslation","Wed [abbreviated weekday]","",,"",1851,"K",1
4306,"ViewTranslation","Thu [abbreviated weekday]","",,"",1851,"N",1
4307,"ViewTranslation","Fri [abbreviated weekday]","",,"",1851,"R",1
4308,"ViewTranslation","Sat [abbreviated weekday]","",,"",1851,"L",1
4309,"ViewTranslation","January [month]","",,"",1851,"Jaanuar",1
4310,"ViewTranslation","February [month]","",,"",1851,"Veebruar",1
4311,"ViewTranslation","March [month]","",,"",1851,"Märts",1
4312,"ViewTranslation","April [month]","",,"",1851,"Aprill",1
4313,"ViewTranslation","May [month]","",,"",1851,"Mai",1
4314,"ViewTranslation","June [month]","",,"",1851,"Juuni",1
4315,"ViewTranslation","July [month]","",,"",1851,"Juuli",1
4316,"ViewTranslation","August [month]","",,"",1851,"August",1
4317,"ViewTranslation","September [month]","",,"",1851,"September",1
4318,"ViewTranslation","October [month]","",,"",1851,"Oktoober",1
4319,"ViewTranslation","November [month]","",,"",1851,"November",1
4320,"ViewTranslation","December [month]","",,"",1851,"Detsember",1
4321,"ViewTranslation","Jan [abbreviated month]","",,"",1851,"Jaan ",1
4322,"ViewTranslation","Feb [abbreviated month]","",,"",1851,"Veebr",1
4323,"ViewTranslation","Mar [abbreviated month]","",,"",1851,"Märts",1
4324,"ViewTranslation","Apr [abbreviated month]","",,"",1851,"Apr ",1
4325,"ViewTranslation","May [abbreviated month]","",,"",1851,"Mai ",1
4326,"ViewTranslation","Jun [abbreviated month]","",,"",1851,"Juuni",1
4327,"ViewTranslation","Jul [abbreviated month]","",,"",1851,"Juuli",1
4328,"ViewTranslation","Aug [abbreviated month]","",,"",1851,"Aug ",1
4329,"ViewTranslation","Sep [abbreviated month]","",,"",1851,"Sept ",1
4330,"ViewTranslation","Oct [abbreviated month]","",,"",1851,"Okt ",1
4331,"ViewTranslation","Nov [abbreviated month]","",,"",1851,"Nov ",1
4332,"ViewTranslation","Dec [abbreviated month]","",,"",1851,"Dets ",1
4333,"ViewTranslation","Sunday [weekday]","",,"",1865,"Igandea",1
4334,"ViewTranslation","Monday [weekday]","",,"",1865,"Astelehena",1
4335,"ViewTranslation","Tuesday [weekday]","",,"",1865,"Asteartea",1
4336,"ViewTranslation","Wednesday [weekday]","",,"",1865,"Asteazkena",1
4337,"ViewTranslation","Thursday [weekday]","",,"",1865,"Osteguna",1
4338,"ViewTranslation","Friday [weekday]","",,"",1865,"Ostirala",1
4339,"ViewTranslation","Saturday [weekday]","",,"",1865,"Larunbata",1
4340,"ViewTranslation","Sun [abbreviated weekday]","",,"",1865,"Ig.",1
4341,"ViewTranslation","Mon [abbreviated weekday]","",,"",1865,"Al.",1
4342,"ViewTranslation","Tue [abbreviated weekday]","",,"",1865,"Ar.",1
4343,"ViewTranslation","Wed [abbreviated weekday]","",,"",1865,"Az.",1
4344,"ViewTranslation","Thu [abbreviated weekday]","",,"",1865,"Og.",1
4345,"ViewTranslation","Fri [abbreviated weekday]","",,"",1865,"Or.",1
4346,"ViewTranslation","Sat [abbreviated weekday]","",,"",1865,"Lr.",1
4347,"ViewTranslation","January [month]","",,"",1865,"Urtarrila",1
4348,"ViewTranslation","February [month]","",,"",1865,"Otsaila",1
4349,"ViewTranslation","March [month]","",,"",1865,"Martxoa",1
4350,"ViewTranslation","April [month]","",,"",1865,"Apirila",1
4351,"ViewTranslation","May [month]","",,"",1865,"Maiatza",1
4352,"ViewTranslation","June [month]","",,"",1865,"Ekaina",1
4353,"ViewTranslation","July [month]","",,"",1865,"Uztaila",1
4354,"ViewTranslation","August [month]","",,"",1865,"Abuztua",1
4355,"ViewTranslation","September [month]","",,"",1865,"Iraila",1
4356,"ViewTranslation","October [month]","",,"",1865,"Urria",1
4357,"ViewTranslation","November [month]","",,"",1865,"Azaroa",1
4358,"ViewTranslation","December [month]","",,"",1865,"Abendua",1
4359,"ViewTranslation","Jan [abbreviated month]","",,"",1865,"Urt",1
4360,"ViewTranslation","Feb [abbreviated month]","",,"",1865,"Ots",1
4361,"ViewTranslation","Mar [abbreviated month]","",,"",1865,"Mar",1
4362,"ViewTranslation","Apr [abbreviated month]","",,"",1865,"Api",1
4363,"ViewTranslation","May [abbreviated month]","",,"",1865,"Mai",1
4364,"ViewTranslation","Jun [abbreviated month]","",,"",1865,"Eka",1
4365,"ViewTranslation","Jul [abbreviated month]","",,"",1865,"Uzt",1
4366,"ViewTranslation","Aug [abbreviated month]","",,"",1865,"Abu",1
4367,"ViewTranslation","Sep [abbreviated month]","",,"",1865,"Ira",1
4368,"ViewTranslation","Oct [abbreviated month]","",,"",1865,"Urr",1
4369,"ViewTranslation","Nov [abbreviated month]","",,"",1865,"Aza",1
4370,"ViewTranslation","Dec [abbreviated month]","",,"",1865,"Abe",1
4371,"ViewTranslation","Sunday [weekday]","",,"",1889,"یک‌شنبه",1
4372,"ViewTranslation","Monday [weekday]","",,"",1889,"دوشنبه",1
4373,"ViewTranslation","Tuesday [weekday]","",,"",1889,"سه‌شنبه",1
4374,"ViewTranslation","Wednesday [weekday]","",,"",1889,"چهارشنبه",1
4375,"ViewTranslation","Thursday [weekday]","",,"",1889,"پنج‌شنبه",1
4376,"ViewTranslation","Friday [weekday]","",,"",1889,"جمعه",1
4377,"ViewTranslation","Saturday [weekday]","",,"",1889,"شنبه",1
4378,"ViewTranslation","Sun [abbreviated weekday]","",,"",1889,"ی.",1
4379,"ViewTranslation","Mon [abbreviated weekday]","",,"",1889,"د.",1
4380,"ViewTranslation","Tue [abbreviated weekday]","",,"",1889,"س.",1
4381,"ViewTranslation","Wed [abbreviated weekday]","",,"",1889,"چ.",1
4382,"ViewTranslation","Thu [abbreviated weekday]","",,"",1889,"پ.",1
4383,"ViewTranslation","Fri [abbreviated weekday]","",,"",1889,"ج.",1
4384,"ViewTranslation","Sat [abbreviated weekday]","",,"",1889,"ش.",1
4385,"ViewTranslation","January [month]","",,"",1889,"ژانویه",1
4386,"ViewTranslation","February [month]","",,"",1889,"فوریه",1
4387,"ViewTranslation","March [month]","",,"",1889,"مارس",1
4388,"ViewTranslation","April [month]","",,"",1889,"آوریل",1
4389,"ViewTranslation","May [month]","",,"",1889,"مه",1
4390,"ViewTranslation","June [month]","",,"",1889,"ژوئن",1
4391,"ViewTranslation","July [month]","",,"",1889,"ژوئیه",1
4392,"ViewTranslation","August [month]","",,"",1889,"اوت",1
4393,"ViewTranslation","September [month]","",,"",1889,"سپتامبر",1
4394,"ViewTranslation","October [month]","",,"",1889,"اكتبر",1
4395,"ViewTranslation","November [month]","",,"",1889,"نوامبر",1
4396,"ViewTranslation","December [month]","",,"",1889,"دسامبر",1
4397,"ViewTranslation","Jan [abbreviated month]","",,"",1889,"ژان",1
4398,"ViewTranslation","Feb [abbreviated month]","",,"",1889,"فور",1
4399,"ViewTranslation","Mar [abbreviated month]","",,"",1889,"مار",1
4400,"ViewTranslation","Apr [abbreviated month]","",,"",1889,"آور",1
4401,"ViewTranslation","May [abbreviated month]","",,"",1889,"مـه",1
4402,"ViewTranslation","Jun [abbreviated month]","",,"",1889,"ژون",1
4403,"ViewTranslation","Jul [abbreviated month]","",,"",1889,"ژوی",1
4404,"ViewTranslation","Aug [abbreviated month]","",,"",1889,"اوت",1
4405,"ViewTranslation","Sep [abbreviated month]","",,"",1889,"سپت",1
4406,"ViewTranslation","Oct [abbreviated month]","",,"",1889,"اكت",1
4407,"ViewTranslation","Nov [abbreviated month]","",,"",1889,"نوا",1
4408,"ViewTranslation","Dec [abbreviated month]","",,"",1889,"دسا",1
4409,"ViewTranslation","Sunday [weekday]","",,"",1903,"Sunnuntai",1
4410,"ViewTranslation","Monday [weekday]","",,"",1903,"Maanantai",1
4411,"ViewTranslation","Tuesday [weekday]","",,"",1903,"Tiistai",1
4412,"ViewTranslation","Wednesday [weekday]","",,"",1903,"Keskiviikko",1
4413,"ViewTranslation","Thursday [weekday]","",,"",1903,"Torstai",1
4414,"ViewTranslation","Friday [weekday]","",,"",1903,"Perjantai",1
4415,"ViewTranslation","Saturday [weekday]","",,"",1903,"Lauantai",1
4416,"ViewTranslation","Sun [abbreviated weekday]","",,"",1903,"Su",1
4417,"ViewTranslation","Mon [abbreviated weekday]","",,"",1903,"Ma",1
4418,"ViewTranslation","Tue [abbreviated weekday]","",,"",1903,"Ti",1
4419,"ViewTranslation","Wed [abbreviated weekday]","",,"",1903,"Ke",1
4420,"ViewTranslation","Thu [abbreviated weekday]","",,"",1903,"To",1
4421,"ViewTranslation","Fri [abbreviated weekday]","",,"",1903,"Pe",1
4422,"ViewTranslation","Sat [abbreviated weekday]","",,"",1903,"La",1
4423,"ViewTranslation","January [month]","",,"",1903,"Tammikuu",1
4424,"ViewTranslation","February [month]","",,"",1903,"Helmikuu",1
4425,"ViewTranslation","March [month]","",,"",1903,"Maaliskuu",1
4426,"ViewTranslation","April [month]","",,"",1903,"Huhtikuu",1
4427,"ViewTranslation","May [month]","",,"",1903,"Toukokuu",1
4428,"ViewTranslation","June [month]","",,"",1903,"Kesäkuu",1
4429,"ViewTranslation","July [month]","",,"",1903,"Heinäkuu",1
4430,"ViewTranslation","August [month]","",,"",1903,"Elokuu",1
4431,"ViewTranslation","September [month]","",,"",1903,"Syyskuu",1
4432,"ViewTranslation","October [month]","",,"",1903,"Lokakuu",1
4433,"ViewTranslation","November [month]","",,"",1903,"Marraskuu",1
4434,"ViewTranslation","December [month]","",,"",1903,"Joulukuu",1
4435,"ViewTranslation","Jan [abbreviated month]","",,"",1903,"Tammi ",1
4436,"ViewTranslation","Feb [abbreviated month]","",,"",1903,"Helmi ",1
4437,"ViewTranslation","Mar [abbreviated month]","",,"",1903,"Maalis",1
4438,"ViewTranslation","Apr [abbreviated month]","",,"",1903,"Huhti ",1
4439,"ViewTranslation","May [abbreviated month]","",,"",1903,"Touko ",1
4440,"ViewTranslation","Jun [abbreviated month]","",,"",1903,"Kesä  ",1
4441,"ViewTranslation","Jul [abbreviated month]","",,"",1903,"Heinä ",1
4442,"ViewTranslation","Aug [abbreviated month]","",,"",1903,"Elo   ",1
4443,"ViewTranslation","Sep [abbreviated month]","",,"",1903,"Syys  ",1
4444,"ViewTranslation","Oct [abbreviated month]","",,"",1903,"Loka  ",1
4445,"ViewTranslation","Nov [abbreviated month]","",,"",1903,"Marras",1
4446,"ViewTranslation","Dec [abbreviated month]","",,"",1903,"Joulu ",1
4447,"ViewTranslation","Sunday [weekday]","",,"",1886,"Sunnudagur",1
4448,"ViewTranslation","Monday [weekday]","",,"",1886,"Mánadagur",1
4449,"ViewTranslation","Tuesday [weekday]","",,"",1886,"Týsdagur",1
4450,"ViewTranslation","Wednesday [weekday]","",,"",1886,"Mikudagur",1
4451,"ViewTranslation","Thursday [weekday]","",,"",1886,"Hósdagur",1
4452,"ViewTranslation","Friday [weekday]","",,"",1886,"Fríggjadagur",1
4453,"ViewTranslation","Saturday [weekday]","",,"",1886,"Leygardagur",1
4454,"ViewTranslation","Sun [abbreviated weekday]","",,"",1886,"Sun",1
4455,"ViewTranslation","Mon [abbreviated weekday]","",,"",1886,"Mán",1
4456,"ViewTranslation","Tue [abbreviated weekday]","",,"",1886,"Týs",1
4457,"ViewTranslation","Wed [abbreviated weekday]","",,"",1886,"Mik",1
4458,"ViewTranslation","Thu [abbreviated weekday]","",,"",1886,"Hós",1
4459,"ViewTranslation","Fri [abbreviated weekday]","",,"",1886,"Frí",1
4460,"ViewTranslation","Sat [abbreviated weekday]","",,"",1886,"Ley",1
4461,"ViewTranslation","January [month]","",,"",1886,"Januar",1
4462,"ViewTranslation","February [month]","",,"",1886,"Februar",1
4463,"ViewTranslation","March [month]","",,"",1886,"Mars",1
4464,"ViewTranslation","April [month]","",,"",1886,"Apríl",1
4465,"ViewTranslation","May [month]","",,"",1886,"Mai",1
4466,"ViewTranslation","June [month]","",,"",1886,"Juni",1
4467,"ViewTranslation","July [month]","",,"",1886,"Juli",1
4468,"ViewTranslation","August [month]","",,"",1886,"August",1
4469,"ViewTranslation","September [month]","",,"",1886,"September",1
4470,"ViewTranslation","October [month]","",,"",1886,"Oktober",1
4471,"ViewTranslation","November [month]","",,"",1886,"November",1
4472,"ViewTranslation","December [month]","",,"",1886,"Desember",1
4473,"ViewTranslation","Jan [abbreviated month]","",,"",1886,"Jan",1
4474,"ViewTranslation","Feb [abbreviated month]","",,"",1886,"Feb",1
4475,"ViewTranslation","Mar [abbreviated month]","",,"",1886,"Mar",1
4476,"ViewTranslation","Apr [abbreviated month]","",,"",1886,"Apr",1
4477,"ViewTranslation","May [abbreviated month]","",,"",1886,"Mai",1
4478,"ViewTranslation","Jun [abbreviated month]","",,"",1886,"Jun",1
4479,"ViewTranslation","Jul [abbreviated month]","",,"",1886,"Jul",1
4480,"ViewTranslation","Aug [abbreviated month]","",,"",1886,"Aug",1
4481,"ViewTranslation","Sep [abbreviated month]","",,"",1886,"Sep",1
4482,"ViewTranslation","Oct [abbreviated month]","",,"",1886,"Okt",1
4483,"ViewTranslation","Nov [abbreviated month]","",,"",1886,"Nov",1
4484,"ViewTranslation","Dec [abbreviated month]","",,"",1886,"Des",1
4485,"ViewTranslation","Sunday [weekday]","",,"",1930,"Dimanche",1
4486,"ViewTranslation","Monday [weekday]","",,"",1930,"Lundi",1
4487,"ViewTranslation","Tuesday [weekday]","",,"",1930,"Mardi",1
4488,"ViewTranslation","Wednesday [weekday]","",,"",1930,"Mercredi",1
4489,"ViewTranslation","Thursday [weekday]","",,"",1930,"Jeudi",1
4490,"ViewTranslation","Friday [weekday]","",,"",1930,"Vendredi",1
4491,"ViewTranslation","Saturday [weekday]","",,"",1930,"Samedi",1
4492,"ViewTranslation","Sun [abbreviated weekday]","",,"",1930,"Dim",1
4493,"ViewTranslation","Mon [abbreviated weekday]","",,"",1930,"Lun",1
4494,"ViewTranslation","Tue [abbreviated weekday]","",,"",1930,"Mar",1
4495,"ViewTranslation","Wed [abbreviated weekday]","",,"",1930,"Mer",1
4496,"ViewTranslation","Thu [abbreviated weekday]","",,"",1930,"Jeu",1
4497,"ViewTranslation","Fri [abbreviated weekday]","",,"",1930,"Ven",1
4498,"ViewTranslation","Sat [abbreviated weekday]","",,"",1930,"Sam",1
4499,"ViewTranslation","January [month]","",,"",1930,"Janvier",1
4500,"ViewTranslation","February [month]","",,"",1930,"Février",1
4501,"ViewTranslation","March [month]","",,"",1930,"Mars",1
4502,"ViewTranslation","April [month]","",,"",1930,"Avril",1
4503,"ViewTranslation","May [month]","",,"",1930,"Mai",1
4504,"ViewTranslation","June [month]","",,"",1930,"Juin",1
4505,"ViewTranslation","July [month]","",,"",1930,"Juillet",1
4506,"ViewTranslation","August [month]","",,"",1930,"Août",1
4507,"ViewTranslation","September [month]","",,"",1930,"Septembre",1
4508,"ViewTranslation","October [month]","",,"",1930,"Octobre",1
4509,"ViewTranslation","November [month]","",,"",1930,"Novembre",1
4510,"ViewTranslation","December [month]","",,"",1930,"Décembre",1
4511,"ViewTranslation","Jan [abbreviated month]","",,"",1930,"Jan",1
4512,"ViewTranslation","Feb [abbreviated month]","",,"",1930,"Fév",1
4513,"ViewTranslation","Mar [abbreviated month]","",,"",1930,"Mar",1
4514,"ViewTranslation","Apr [abbreviated month]","",,"",1930,"Avr",1
4515,"ViewTranslation","May [abbreviated month]","",,"",1930,"Mai",1
4516,"ViewTranslation","Jun [abbreviated month]","",,"",1930,"Jun",1
4517,"ViewTranslation","Jul [abbreviated month]","",,"",1930,"Jui",1
4518,"ViewTranslation","Aug [abbreviated month]","",,"",1930,"Aoû",1
4519,"ViewTranslation","Sep [abbreviated month]","",,"",1930,"Sep",1
4520,"ViewTranslation","Oct [abbreviated month]","",,"",1930,"Oct",1
4521,"ViewTranslation","Nov [abbreviated month]","",,"",1930,"Nov",1
4522,"ViewTranslation","Dec [abbreviated month]","",,"",1930,"Déc",1
4523,"ViewTranslation","Sunday [weekday]","",,"",2115,"Dé domhnaigh",1
4524,"ViewTranslation","Monday [weekday]","",,"",2115,"Dé luain",1
4525,"ViewTranslation","Tuesday [weekday]","",,"",2115,"Dé máirt",1
4526,"ViewTranslation","Wednesday [weekday]","",,"",2115,"Dé céadaoin",1
4527,"ViewTranslation","Thursday [weekday]","",,"",2115,"Déardaoin",1
4528,"ViewTranslation","Friday [weekday]","",,"",2115,"Dé haoine",1
4529,"ViewTranslation","Saturday [weekday]","",,"",2115,"Dé sathairn",1
4530,"ViewTranslation","Sun [abbreviated weekday]","",,"",2115,"Domh",1
4531,"ViewTranslation","Mon [abbreviated weekday]","",,"",2115,"Luan",1
4532,"ViewTranslation","Tue [abbreviated weekday]","",,"",2115,"Máirt",1
4533,"ViewTranslation","Wed [abbreviated weekday]","",,"",2115,"Céad",1
4534,"ViewTranslation","Thu [abbreviated weekday]","",,"",2115,"Déar",1
4535,"ViewTranslation","Fri [abbreviated weekday]","",,"",2115,"Aoine",1
4536,"ViewTranslation","Sat [abbreviated weekday]","",,"",2115,"Sath",1
4537,"ViewTranslation","January [month]","",,"",2115,"Eanáir",1
4538,"ViewTranslation","February [month]","",,"",2115,"Feabhra",1
4539,"ViewTranslation","March [month]","",,"",2115,"Márta",1
4540,"ViewTranslation","April [month]","",,"",2115,"Aibreán",1
4541,"ViewTranslation","May [month]","",,"",2115,"Mí na bealtaine",1
4542,"ViewTranslation","June [month]","",,"",2115,"Meith",1
4543,"ViewTranslation","July [month]","",,"",2115,"Iúil",1
4544,"ViewTranslation","August [month]","",,"",2115,"Lúnasa",1
4545,"ViewTranslation","September [month]","",,"",2115,"Meán fómhair",1
4546,"ViewTranslation","October [month]","",,"",2115,"Deireadh fómhair",1
4547,"ViewTranslation","November [month]","",,"",2115,"Mí na samhna",1
4548,"ViewTranslation","December [month]","",,"",2115,"Mí na nollag",1
4549,"ViewTranslation","Jan [abbreviated month]","",,"",2115,"Ean",1
4550,"ViewTranslation","Feb [abbreviated month]","",,"",2115,"Feabh",1
4551,"ViewTranslation","Mar [abbreviated month]","",,"",2115,"Márta",1
4552,"ViewTranslation","Apr [abbreviated month]","",,"",2115,"Aib",1
4553,"ViewTranslation","May [abbreviated month]","",,"",2115,"Beal",1
4554,"ViewTranslation","Jun [abbreviated month]","",,"",2115,"Meith",1
4555,"ViewTranslation","Jul [abbreviated month]","",,"",2115,"Iúil",1
4556,"ViewTranslation","Aug [abbreviated month]","",,"",2115,"Lún",1
4557,"ViewTranslation","Sep [abbreviated month]","",,"",2115,"Mfómh",1
4558,"ViewTranslation","Oct [abbreviated month]","",,"",2115,"Dfómh",1
4559,"ViewTranslation","Nov [abbreviated month]","",,"",2115,"Samh",1
4560,"ViewTranslation","Dec [abbreviated month]","",,"",2115,"Noll",1
4561,"ViewTranslation","Sunday [weekday]","",,"",2112,"Didòmhnaich",1
4562,"ViewTranslation","Monday [weekday]","",,"",2112,"Diluain",1
4563,"ViewTranslation","Tuesday [weekday]","",,"",2112,"Dimàirt",1
4564,"ViewTranslation","Wednesday [weekday]","",,"",2112,"Diciadain",1
4565,"ViewTranslation","Thursday [weekday]","",,"",2112,"Diardaoin",1
4566,"ViewTranslation","Friday [weekday]","",,"",2112,"Dihaoine",1
4567,"ViewTranslation","Saturday [weekday]","",,"",2112,"Disathairne",1
4568,"ViewTranslation","Sun [abbreviated weekday]","",,"",2112,"Dido",1
4569,"ViewTranslation","Mon [abbreviated weekday]","",,"",2112,"Dilu",1
4570,"ViewTranslation","Tue [abbreviated weekday]","",,"",2112,"Dim",1
4571,"ViewTranslation","Wed [abbreviated weekday]","",,"",2112,"Dic",1
4572,"ViewTranslation","Thu [abbreviated weekday]","",,"",2112,"Diar",1
4573,"ViewTranslation","Fri [abbreviated weekday]","",,"",2112,"Diha",1
4574,"ViewTranslation","Sat [abbreviated weekday]","",,"",2112,"Disa",1
4575,"ViewTranslation","January [month]","",,"",2112,"Am faoilteach",1
4576,"ViewTranslation","February [month]","",,"",2112,"An gearran",1
4577,"ViewTranslation","March [month]","",,"",2112,"Am màrt",1
4578,"ViewTranslation","April [month]","",,"",2112,"An giblean",1
4579,"ViewTranslation","May [month]","",,"",2112,"A' mhàigh",1
4580,"ViewTranslation","June [month]","",,"",2112,"An t-mhìos",1
4581,"ViewTranslation","July [month]","",,"",2112,"An t-luchar",1
4582,"ViewTranslation","August [month]","",,"",2112,"An lùnasdal",1
4583,"ViewTranslation","September [month]","",,"",2112,"An t-sultain",1
4584,"ViewTranslation","October [month]","",,"",2112,"An damhair",1
4585,"ViewTranslation","November [month]","",,"",2112,"An t-samhain",1
4586,"ViewTranslation","December [month]","",,"",2112,"An dùbhlachd",1
4587,"ViewTranslation","Jan [abbreviated month]","",,"",2112,"Fao",1
4588,"ViewTranslation","Feb [abbreviated month]","",,"",2112,"Gea",1
4589,"ViewTranslation","Mar [abbreviated month]","",,"",2112,"Màr",1
4590,"ViewTranslation","Apr [abbreviated month]","",,"",2112,"Gib",1
4591,"ViewTranslation","May [abbreviated month]","",,"",2112,"Mhà",1
4592,"ViewTranslation","Jun [abbreviated month]","",,"",2112,"Ogm",1
4593,"ViewTranslation","Jul [abbreviated month]","",,"",2112,"Luc",1
4594,"ViewTranslation","Aug [abbreviated month]","",,"",2112,"Lùn",1
4595,"ViewTranslation","Sep [abbreviated month]","",,"",2112,"Sul",1
4596,"ViewTranslation","Oct [abbreviated month]","",,"",2112,"Dam",1
4597,"ViewTranslation","Nov [abbreviated month]","",,"",2112,"Sam",1
4598,"ViewTranslation","Dec [abbreviated month]","",,"",2112,"Dùb",1
4599,"ViewTranslation","Sunday [weekday]","",,"",2116,"Domingo",1
4600,"ViewTranslation","Monday [weekday]","",,"",2116,"Luns",1
4601,"ViewTranslation","Tuesday [weekday]","",,"",2116,"Martes",1
4602,"ViewTranslation","Wednesday [weekday]","",,"",2116,"Mércores",1
4603,"ViewTranslation","Thursday [weekday]","",,"",2116,"Xoves",1
4604,"ViewTranslation","Friday [weekday]","",,"",2116,"Venres",1
4605,"ViewTranslation","Saturday [weekday]","",,"",2116,"Sábado",1
4606,"ViewTranslation","Sun [abbreviated weekday]","",,"",2116,"Dom",1
4607,"ViewTranslation","Mon [abbreviated weekday]","",,"",2116,"Lun",1
4608,"ViewTranslation","Tue [abbreviated weekday]","",,"",2116,"Mar",1
4609,"ViewTranslation","Wed [abbreviated weekday]","",,"",2116,"Mér",1
4610,"ViewTranslation","Thu [abbreviated weekday]","",,"",2116,"Xov",1
4611,"ViewTranslation","Fri [abbreviated weekday]","",,"",2116,"Ven",1
4612,"ViewTranslation","Sat [abbreviated weekday]","",,"",2116,"Sáb",1
4613,"ViewTranslation","January [month]","",,"",2116,"Xaneiro",1
4614,"ViewTranslation","February [month]","",,"",2116,"Febreiro",1
4615,"ViewTranslation","March [month]","",,"",2116,"Marzo",1
4616,"ViewTranslation","April [month]","",,"",2116,"Abril",1
4617,"ViewTranslation","May [month]","",,"",2116,"Maio",1
4618,"ViewTranslation","June [month]","",,"",2116,"Xuño",1
4619,"ViewTranslation","July [month]","",,"",2116,"Xullo",1
4620,"ViewTranslation","August [month]","",,"",2116,"Agosto",1
4621,"ViewTranslation","September [month]","",,"",2116,"Setembro",1
4622,"ViewTranslation","October [month]","",,"",2116,"Outubro",1
4623,"ViewTranslation","November [month]","",,"",2116,"Novembro",1
4624,"ViewTranslation","December [month]","",,"",2116,"Decembro",1
4625,"ViewTranslation","Jan [abbreviated month]","",,"",2116,"Xan",1
4626,"ViewTranslation","Feb [abbreviated month]","",,"",2116,"Feb",1
4627,"ViewTranslation","Mar [abbreviated month]","",,"",2116,"Mar",1
4628,"ViewTranslation","Apr [abbreviated month]","",,"",2116,"Abr",1
4629,"ViewTranslation","May [abbreviated month]","",,"",2116,"Mai",1
4630,"ViewTranslation","Jun [abbreviated month]","",,"",2116,"Xuñ",1
4631,"ViewTranslation","Jul [abbreviated month]","",,"",2116,"Xul",1
4632,"ViewTranslation","Aug [abbreviated month]","",,"",2116,"Ago",1
4633,"ViewTranslation","Sep [abbreviated month]","",,"",2116,"Set",1
4634,"ViewTranslation","Oct [abbreviated month]","",,"",2116,"Out",1
4635,"ViewTranslation","Nov [abbreviated month]","",,"",2116,"Nov",1
4636,"ViewTranslation","Dec [abbreviated month]","",,"",2116,"Dec",1
4637,"ViewTranslation","Sunday [weekday]","",,"",2226,"રવિવાર",1
4638,"ViewTranslation","Monday [weekday]","",,"",2226,"સોમવાર",1
4639,"ViewTranslation","Tuesday [weekday]","",,"",2226,"મન્ગળવાર",1
4640,"ViewTranslation","Wednesday [weekday]","",,"",2226,"બુધવાર",1
4641,"ViewTranslation","Thursday [weekday]","",,"",2226,"ગુરુવાર",1
4642,"ViewTranslation","Friday [weekday]","",,"",2226,"શુક્રવાર",1
4643,"ViewTranslation","Saturday [weekday]","",,"",2226,"શનિવાર",1
4644,"ViewTranslation","Sun [abbreviated weekday]","",,"",2226,"રવિ",1
4645,"ViewTranslation","Mon [abbreviated weekday]","",,"",2226,"સોમ",1
4646,"ViewTranslation","Tue [abbreviated weekday]","",,"",2226,"મન્ગળ",1
4647,"ViewTranslation","Wed [abbreviated weekday]","",,"",2226,"બુધ",1
4648,"ViewTranslation","Thu [abbreviated weekday]","",,"",2226,"ગુરુ",1
4649,"ViewTranslation","Fri [abbreviated weekday]","",,"",2226,"શુક્ર",1
4650,"ViewTranslation","Sat [abbreviated weekday]","",,"",2226,"શનિ",1
4651,"ViewTranslation","January [month]","",,"",2226,"જાન્યુઆરી",1
4652,"ViewTranslation","February [month]","",,"",2226,"ફેબ્રુઆરી",1
4653,"ViewTranslation","March [month]","",,"",2226,"માર્ચ",1
4654,"ViewTranslation","April [month]","",,"",2226,"એપ્રિલ",1
4655,"ViewTranslation","May [month]","",,"",2226,"મે",1
4656,"ViewTranslation","June [month]","",,"",2226,"જુન",1
4657,"ViewTranslation","July [month]","",,"",2226,"જુલાઇ",1
4658,"ViewTranslation","August [month]","",,"",2226,"ઓગસ્ટ",1
4659,"ViewTranslation","September [month]","",,"",2226,"સેપ્ટેમ્બર",1
4660,"ViewTranslation","October [month]","",,"",2226,"ઓક્ટોબર",1
4661,"ViewTranslation","November [month]","",,"",2226,"નવેમ્બર",1
4662,"ViewTranslation","December [month]","",,"",2226,"ડિસેમ્બર",1
4663,"ViewTranslation","Jan [abbreviated month]","",,"",2226,"જાન",1
4664,"ViewTranslation","Feb [abbreviated month]","",,"",2226,"ફેબ",1
4665,"ViewTranslation","Mar [abbreviated month]","",,"",2226,"માર",1
4666,"ViewTranslation","Apr [abbreviated month]","",,"",2226,"એપ્ર",1
4667,"ViewTranslation","May [abbreviated month]","",,"",2226,"મે",1
4668,"ViewTranslation","Jun [abbreviated month]","",,"",2226,"જુન",1
4669,"ViewTranslation","Jul [abbreviated month]","",,"",2226,"જુલ",1
4670,"ViewTranslation","Aug [abbreviated month]","",,"",2226,"ઓગ",1
4671,"ViewTranslation","Sep [abbreviated month]","",,"",2226,"સેપ્ટ",1
4672,"ViewTranslation","Oct [abbreviated month]","",,"",2226,"ઓક્ટ",1
4673,"ViewTranslation","Nov [abbreviated month]","",,"",2226,"નોવ",1
4674,"ViewTranslation","Dec [abbreviated month]","",,"",2226,"ડિસ",1
4675,"ViewTranslation","Sunday [weekday]","",,"",2125,"Jedoonee",1
4676,"ViewTranslation","Monday [weekday]","",,"",2125,"Jelhein",1
4677,"ViewTranslation","Tuesday [weekday]","",,"",2125,"Jemayrt",1
4678,"ViewTranslation","Wednesday [weekday]","",,"",2125,"Jercean",1
4679,"ViewTranslation","Thursday [weekday]","",,"",2125,"Jerdein",1
4680,"ViewTranslation","Friday [weekday]","",,"",2125,"Jeheiney",1
4681,"ViewTranslation","Saturday [weekday]","",,"",2125,"Jesarn",1
4682,"ViewTranslation","Sun [abbreviated weekday]","",,"",2125,"Jed",1
4683,"ViewTranslation","Mon [abbreviated weekday]","",,"",2125,"Jel",1
4684,"ViewTranslation","Tue [abbreviated weekday]","",,"",2125,"Jem",1
4685,"ViewTranslation","Wed [abbreviated weekday]","",,"",2125,"Jerc",1
4686,"ViewTranslation","Thu [abbreviated weekday]","",,"",2125,"Jerd",1
4687,"ViewTranslation","Fri [abbreviated weekday]","",,"",2125,"Jeh",1
4688,"ViewTranslation","Sat [abbreviated weekday]","",,"",2125,"Jes",1
4689,"ViewTranslation","January [month]","",,"",2125,"Jerrey-geuree",1
4690,"ViewTranslation","February [month]","",,"",2125,"Toshiaght-arree",1
4691,"ViewTranslation","March [month]","",,"",2125,"Mayrnt",1
4692,"ViewTranslation","April [month]","",,"",2125,"Averil",1
4693,"ViewTranslation","May [month]","",,"",2125,"Boaldyn",1
4694,"ViewTranslation","June [month]","",,"",2125,"Mean-souree",1
4695,"ViewTranslation","July [month]","",,"",2125,"Jerrey-souree",1
4696,"ViewTranslation","August [month]","",,"",2125,"Luanistyn",1
4697,"ViewTranslation","September [month]","",,"",2125,"Mean-fouyir",1
4698,"ViewTranslation","October [month]","",,"",2125,"Jerrey-fouyir",1
4699,"ViewTranslation","November [month]","",,"",2125,"Mee houney",1
4700,"ViewTranslation","December [month]","",,"",2125,"Mee ny nollick",1
4701,"ViewTranslation","Jan [abbreviated month]","",,"",2125,"J-guer",1
4702,"ViewTranslation","Feb [abbreviated month]","",,"",2125,"T-arree",1
4703,"ViewTranslation","Mar [abbreviated month]","",,"",2125,"Mayrnt",1
4704,"ViewTranslation","Apr [abbreviated month]","",,"",2125,"Avrril",1
4705,"ViewTranslation","May [abbreviated month]","",,"",2125,"Boaldyn",1
4706,"ViewTranslation","Jun [abbreviated month]","",,"",2125,"M-souree",1
4707,"ViewTranslation","Jul [abbreviated month]","",,"",2125,"J-souree",1
4708,"ViewTranslation","Aug [abbreviated month]","",,"",2125,"Luanistyn",1
4709,"ViewTranslation","Sep [abbreviated month]","",,"",2125,"M-fouyir",1
4710,"ViewTranslation","Oct [abbreviated month]","",,"",2125,"J-fouyir",1
4711,"ViewTranslation","Nov [abbreviated month]","",,"",2125,"M.houney",1
4712,"ViewTranslation","Dec [abbreviated month]","",,"",2125,"M.nollick",1
4713,"ViewTranslation","Sunday [weekday]","",,"",2323,"יום ראשון",1
4714,"ViewTranslation","Monday [weekday]","",,"",2323,"יום שני",1
4715,"ViewTranslation","Tuesday [weekday]","",,"",2323,"יום שלישי",1
4716,"ViewTranslation","Wednesday [weekday]","",,"",2323,"יום רביעי",1
4717,"ViewTranslation","Thursday [weekday]","",,"",2323,"יום חמישי",1
4718,"ViewTranslation","Friday [weekday]","",,"",2323,"יום ששי",1
4719,"ViewTranslation","Saturday [weekday]","",,"",2323,"יום שבת",1
4720,"ViewTranslation","Sun [abbreviated weekday]","",,"",2323,"יום א'",1
4721,"ViewTranslation","Mon [abbreviated weekday]","",,"",2323,"יום ב'",1
4722,"ViewTranslation","Tue [abbreviated weekday]","",,"",2323,"יום ג'",1
4723,"ViewTranslation","Wed [abbreviated weekday]","",,"",2323,"יום ד'",1
4724,"ViewTranslation","Thu [abbreviated weekday]","",,"",2323,"יום ה'",1
4725,"ViewTranslation","Fri [abbreviated weekday]","",,"",2323,"יום ו'",1
4726,"ViewTranslation","Sat [abbreviated weekday]","",,"",2323,"שבת",1
4727,"ViewTranslation","January [month]","",,"",2323,"ינואר",1
4728,"ViewTranslation","February [month]","",,"",2323,"פברואר",1
4729,"ViewTranslation","March [month]","",,"",2323,"מרץ",1
4730,"ViewTranslation","April [month]","",,"",2323,"אפריל",1
4731,"ViewTranslation","May [month]","",,"",2323,"מאי",1
4732,"ViewTranslation","June [month]","",,"",2323,"יוני",1
4733,"ViewTranslation","July [month]","",,"",2323,"יולי",1
4734,"ViewTranslation","August [month]","",,"",2323,"אוגוסט",1
4735,"ViewTranslation","September [month]","",,"",2323,"ספטמבר",1
4736,"ViewTranslation","October [month]","",,"",2323,"אוקטובר",1
4737,"ViewTranslation","November [month]","",,"",2323,"נובמבר",1
4738,"ViewTranslation","December [month]","",,"",2323,"דצמבר",1
4739,"ViewTranslation","Jan [abbreviated month]","",,"",2323,"ינו",1
4740,"ViewTranslation","Feb [abbreviated month]","",,"",2323,"פבר",1
4741,"ViewTranslation","Mar [abbreviated month]","",,"",2323,"מרץ",1
4742,"ViewTranslation","Apr [abbreviated month]","",,"",2323,"אפר",1
4743,"ViewTranslation","May [abbreviated month]","",,"",2323,"מאי",1
4744,"ViewTranslation","Jun [abbreviated month]","",,"",2323,"יונ",1
4745,"ViewTranslation","Jul [abbreviated month]","",,"",2323,"יול",1
4746,"ViewTranslation","Aug [abbreviated month]","",,"",2323,"אוג",1
4747,"ViewTranslation","Sep [abbreviated month]","",,"",2323,"ספט",1
4748,"ViewTranslation","Oct [abbreviated month]","",,"",2323,"אוק",1
4749,"ViewTranslation","Nov [abbreviated month]","",,"",2323,"נוב",1
4750,"ViewTranslation","Dec [abbreviated month]","",,"",2323,"דצמ",1
4751,"ViewTranslation","Sunday [weekday]","",,"",2343,"रविवार ",1
4752,"ViewTranslation","Monday [weekday]","",,"",2343,"सोमवार ",1
4753,"ViewTranslation","Tuesday [weekday]","",,"",2343,"मंगलवार ",1
4754,"ViewTranslation","Wednesday [weekday]","",,"",2343,"बुधवार ",1
4755,"ViewTranslation","Thursday [weekday]","",,"",2343,"गुरुवार ",1
4756,"ViewTranslation","Friday [weekday]","",,"",2343,"शुक्रवार ",1
4757,"ViewTranslation","Saturday [weekday]","",,"",2343,"शनिवार ",1
4758,"ViewTranslation","Sun [abbreviated weekday]","",,"",2343,"रवि ",1
4759,"ViewTranslation","Mon [abbreviated weekday]","",,"",2343,"सोम ",1
4760,"ViewTranslation","Tue [abbreviated weekday]","",,"",2343,"मंगल ",1
4761,"ViewTranslation","Wed [abbreviated weekday]","",,"",2343,"बुध ",1
4762,"ViewTranslation","Thu [abbreviated weekday]","",,"",2343,"गुरु ",1
4763,"ViewTranslation","Fri [abbreviated weekday]","",,"",2343,"शुक्र ",1
4764,"ViewTranslation","Sat [abbreviated weekday]","",,"",2343,"शनि ",1
4765,"ViewTranslation","January [month]","",,"",2343,"जनवरी",1
4766,"ViewTranslation","February [month]","",,"",2343,"फ़रवरी",1
4767,"ViewTranslation","March [month]","",,"",2343,"मार्च",1
4768,"ViewTranslation","April [month]","",,"",2343,"अप्र ल",1
4769,"ViewTranslation","May [month]","",,"",2343,"मई",1
4770,"ViewTranslation","June [month]","",,"",2343,"जून",1
4771,"ViewTranslation","July [month]","",,"",2343,"जुलाई",1
4772,"ViewTranslation","August [month]","",,"",2343,"अगस्त",1
4773,"ViewTranslation","September [month]","",,"",2343,"सितम्बर",1
4774,"ViewTranslation","October [month]","",,"",2343,"अक्टूबर",1
4775,"ViewTranslation","November [month]","",,"",2343,"नवम्बर",1
4776,"ViewTranslation","December [month]","",,"",2343,"दिसम्बर",1
4777,"ViewTranslation","Jan [abbreviated month]","",,"",2343,"जनवरी",1
4778,"ViewTranslation","Feb [abbreviated month]","",,"",2343,"फ़रवरी",1
4779,"ViewTranslation","Mar [abbreviated month]","",,"",2343,"मार्च",1
4780,"ViewTranslation","Apr [abbreviated month]","",,"",2343,"अप्र ल",1
4781,"ViewTranslation","May [abbreviated month]","",,"",2343,"मई",1
4782,"ViewTranslation","Jun [abbreviated month]","",,"",2343,"जून",1
4783,"ViewTranslation","Jul [abbreviated month]","",,"",2343,"जुलाई",1
4784,"ViewTranslation","Aug [abbreviated month]","",,"",2343,"अगस्त",1
4785,"ViewTranslation","Sep [abbreviated month]","",,"",2343,"सितम्बर",1
4786,"ViewTranslation","Oct [abbreviated month]","",,"",2343,"अक्टूबर",1
4787,"ViewTranslation","Nov [abbreviated month]","",,"",2343,"नवम्बर",1
4788,"ViewTranslation","Dec [abbreviated month]","",,"",2343,"दिसम्बर",1
4789,"ViewTranslation","Sunday [weekday]","",,"",2418,"Nedjelja",1
4790,"ViewTranslation","Monday [weekday]","",,"",2418,"Ponedjeljak",1
4791,"ViewTranslation","Tuesday [weekday]","",,"",2418,"Utorak",1
4792,"ViewTranslation","Wednesday [weekday]","",,"",2418,"Srijeda",1
4793,"ViewTranslation","Thursday [weekday]","",,"",2418,"Četvrtak",1
4794,"ViewTranslation","Friday [weekday]","",,"",2418,"Petak",1
4795,"ViewTranslation","Saturday [weekday]","",,"",2418,"Subota",1
4796,"ViewTranslation","Sun [abbreviated weekday]","",,"",2418,"Ned",1
4797,"ViewTranslation","Mon [abbreviated weekday]","",,"",2418,"Pon",1
4798,"ViewTranslation","Tue [abbreviated weekday]","",,"",2418,"Uto",1
4799,"ViewTranslation","Wed [abbreviated weekday]","",,"",2418,"Sri",1
4800,"ViewTranslation","Thu [abbreviated weekday]","",,"",2418,"Čet",1
4801,"ViewTranslation","Fri [abbreviated weekday]","",,"",2418,"Pet",1
4802,"ViewTranslation","Sat [abbreviated weekday]","",,"",2418,"Sub",1
4803,"ViewTranslation","January [month]","",,"",2418,"Siječanj",1
4804,"ViewTranslation","February [month]","",,"",2418,"Veljača",1
4805,"ViewTranslation","March [month]","",,"",2418,"Ožujak",1
4806,"ViewTranslation","April [month]","",,"",2418,"Travanj",1
4807,"ViewTranslation","May [month]","",,"",2418,"Svibanj",1
4808,"ViewTranslation","June [month]","",,"",2418,"Lipanj",1
4809,"ViewTranslation","July [month]","",,"",2418,"Srpanj",1
4810,"ViewTranslation","August [month]","",,"",2418,"Kolovoz",1
4811,"ViewTranslation","September [month]","",,"",2418,"Rujan",1
4812,"ViewTranslation","October [month]","",,"",2418,"Listopad",1
4813,"ViewTranslation","November [month]","",,"",2418,"Studeni",1
4814,"ViewTranslation","December [month]","",,"",2418,"Prosinac",1
4815,"ViewTranslation","Jan [abbreviated month]","",,"",2418,"Sij",1
4816,"ViewTranslation","Feb [abbreviated month]","",,"",2418,"Vel",1
4817,"ViewTranslation","Mar [abbreviated month]","",,"",2418,"Ožu",1
4818,"ViewTranslation","Apr [abbreviated month]","",,"",2418,"Tra",1
4819,"ViewTranslation","May [abbreviated month]","",,"",2418,"Svi",1
4820,"ViewTranslation","Jun [abbreviated month]","",,"",2418,"Lip",1
4821,"ViewTranslation","Jul [abbreviated month]","",,"",2418,"Srp",1
4822,"ViewTranslation","Aug [abbreviated month]","",,"",2418,"Kol",1
4823,"ViewTranslation","Sep [abbreviated month]","",,"",2418,"Ruj",1
4824,"ViewTranslation","Oct [abbreviated month]","",,"",2418,"Lis",1
4825,"ViewTranslation","Nov [abbreviated month]","",,"",2418,"Stu",1
4826,"ViewTranslation","Dec [abbreviated month]","",,"",2418,"Pro",1
4827,"ViewTranslation","Sunday [weekday]","",,"",2443,"Vasárnap",1
4828,"ViewTranslation","Monday [weekday]","",,"",2443,"Hétfő",1
4829,"ViewTranslation","Tuesday [weekday]","",,"",2443,"Kedd",1
4830,"ViewTranslation","Wednesday [weekday]","",,"",2443,"Szerda",1
4831,"ViewTranslation","Thursday [weekday]","",,"",2443,"Csütörtök",1
4832,"ViewTranslation","Friday [weekday]","",,"",2443,"Péntek",1
4833,"ViewTranslation","Saturday [weekday]","",,"",2443,"Szombat",1
4834,"ViewTranslation","Sun [abbreviated weekday]","",,"",2443,"v",1
4835,"ViewTranslation","Mon [abbreviated weekday]","",,"",2443,"h",1
4836,"ViewTranslation","Tue [abbreviated weekday]","",,"",2443,"k",1
4837,"ViewTranslation","Wed [abbreviated weekday]","",,"",2443,"Sze",1
4838,"ViewTranslation","Thu [abbreviated weekday]","",,"",2443,"Cs",1
4839,"ViewTranslation","Fri [abbreviated weekday]","",,"",2443,"p",1
4840,"ViewTranslation","Sat [abbreviated weekday]","",,"",2443,"Szo",1
4841,"ViewTranslation","January [month]","",,"",2443,"Január",1
4842,"ViewTranslation","February [month]","",,"",2443,"Február",1
4843,"ViewTranslation","March [month]","",,"",2443,"Március",1
4844,"ViewTranslation","April [month]","",,"",2443,"Április",1
4845,"ViewTranslation","May [month]","",,"",2443,"Május",1
4846,"ViewTranslation","June [month]","",,"",2443,"Június",1
4847,"ViewTranslation","July [month]","",,"",2443,"Július",1
4848,"ViewTranslation","August [month]","",,"",2443,"Augusztus",1
4849,"ViewTranslation","September [month]","",,"",2443,"Szeptember",1
4850,"ViewTranslation","October [month]","",,"",2443,"Október",1
4851,"ViewTranslation","November [month]","",,"",2443,"November",1
4852,"ViewTranslation","December [month]","",,"",2443,"December",1
4853,"ViewTranslation","Jan [abbreviated month]","",,"",2443,"Jan",1
4854,"ViewTranslation","Feb [abbreviated month]","",,"",2443,"Feb",1
4855,"ViewTranslation","Mar [abbreviated month]","",,"",2443,"Már",1
4856,"ViewTranslation","Apr [abbreviated month]","",,"",2443,"Ápr",1
4857,"ViewTranslation","May [abbreviated month]","",,"",2443,"Máj",1
4858,"ViewTranslation","Jun [abbreviated month]","",,"",2443,"Jún",1
4859,"ViewTranslation","Jul [abbreviated month]","",,"",2443,"Júl",1
4860,"ViewTranslation","Aug [abbreviated month]","",,"",2443,"Aug",1
4861,"ViewTranslation","Sep [abbreviated month]","",,"",2443,"Sze",1
4862,"ViewTranslation","Oct [abbreviated month]","",,"",2443,"Okt",1
4863,"ViewTranslation","Nov [abbreviated month]","",,"",2443,"Nov",1
4864,"ViewTranslation","Dec [abbreviated month]","",,"",2443,"Dec",1
4865,"ViewTranslation","Sunday [weekday]","",,"",2558,"Minggu",1
4866,"ViewTranslation","Monday [weekday]","",,"",2558,"Senin",1
4867,"ViewTranslation","Tuesday [weekday]","",,"",2558,"Selasa",1
4868,"ViewTranslation","Wednesday [weekday]","",,"",2558,"Rabu",1
4869,"ViewTranslation","Thursday [weekday]","",,"",2558,"Kamis",1
4870,"ViewTranslation","Friday [weekday]","",,"",2558,"Jumat",1
4871,"ViewTranslation","Saturday [weekday]","",,"",2558,"Sabtu",1
4872,"ViewTranslation","Sun [abbreviated weekday]","",,"",2558,"Min",1
4873,"ViewTranslation","Mon [abbreviated weekday]","",,"",2558,"Sen",1
4874,"ViewTranslation","Tue [abbreviated weekday]","",,"",2558,"Sel",1
4875,"ViewTranslation","Wed [abbreviated weekday]","",,"",2558,"Rab",1
4876,"ViewTranslation","Thu [abbreviated weekday]","",,"",2558,"Kam",1
4877,"ViewTranslation","Fri [abbreviated weekday]","",,"",2558,"Jum",1
4878,"ViewTranslation","Sat [abbreviated weekday]","",,"",2558,"Sab",1
4879,"ViewTranslation","January [month]","",,"",2558,"Januari",1
4880,"ViewTranslation","February [month]","",,"",2558,"Pebruari",1
4881,"ViewTranslation","March [month]","",,"",2558,"Maret",1
4882,"ViewTranslation","April [month]","",,"",2558,"April",1
4883,"ViewTranslation","May [month]","",,"",2558,"Mei",1
4884,"ViewTranslation","June [month]","",,"",2558,"Juni",1
4885,"ViewTranslation","July [month]","",,"",2558,"Juli",1
4886,"ViewTranslation","August [month]","",,"",2558,"Agustus",1
4887,"ViewTranslation","September [month]","",,"",2558,"September",1
4888,"ViewTranslation","October [month]","",,"",2558,"Oktober",1
4889,"ViewTranslation","November [month]","",,"",2558,"November",1
4890,"ViewTranslation","December [month]","",,"",2558,"Desember",1
4891,"ViewTranslation","Jan [abbreviated month]","",,"",2558,"Jan",1
4892,"ViewTranslation","Feb [abbreviated month]","",,"",2558,"Peb",1
4893,"ViewTranslation","Mar [abbreviated month]","",,"",2558,"Mar",1
4894,"ViewTranslation","Apr [abbreviated month]","",,"",2558,"Apr",1
4895,"ViewTranslation","May [abbreviated month]","",,"",2558,"Mei",1
4896,"ViewTranslation","Jun [abbreviated month]","",,"",2558,"Jun",1
4897,"ViewTranslation","Jul [abbreviated month]","",,"",2558,"Jul",1
4898,"ViewTranslation","Aug [abbreviated month]","",,"",2558,"Agu",1
4899,"ViewTranslation","Sep [abbreviated month]","",,"",2558,"Sep",1
4900,"ViewTranslation","Oct [abbreviated month]","",,"",2558,"Okt",1
4901,"ViewTranslation","Nov [abbreviated month]","",,"",2558,"Nov",1
4902,"ViewTranslation","Dec [abbreviated month]","",,"",2558,"Des",1
4903,"ViewTranslation","Sunday [weekday]","",,"",2593,"Sunnudagur",1
4904,"ViewTranslation","Monday [weekday]","",,"",2593,"Mánudagur",1
4905,"ViewTranslation","Tuesday [weekday]","",,"",2593,"Þriðjudagur",1
4906,"ViewTranslation","Wednesday [weekday]","",,"",2593,"Miðvikudagur",1
4907,"ViewTranslation","Thursday [weekday]","",,"",2593,"Fimmtudagur",1
4908,"ViewTranslation","Friday [weekday]","",,"",2593,"Föstudagur",1
4909,"ViewTranslation","Saturday [weekday]","",,"",2593,"Laugardagur",1
4910,"ViewTranslation","Sun [abbreviated weekday]","",,"",2593,"Sun",1
4911,"ViewTranslation","Mon [abbreviated weekday]","",,"",2593,"Mán",1
4912,"ViewTranslation","Tue [abbreviated weekday]","",,"",2593,"Þri",1
4913,"ViewTranslation","Wed [abbreviated weekday]","",,"",2593,"Mið",1
4914,"ViewTranslation","Thu [abbreviated weekday]","",,"",2593,"Fim",1
4915,"ViewTranslation","Fri [abbreviated weekday]","",,"",2593,"Fös",1
4916,"ViewTranslation","Sat [abbreviated weekday]","",,"",2593,"Lau",1
4917,"ViewTranslation","January [month]","",,"",2593,"Janúar",1
4918,"ViewTranslation","February [month]","",,"",2593,"Febrúar",1
4919,"ViewTranslation","March [month]","",,"",2593,"Mars",1
4920,"ViewTranslation","April [month]","",,"",2593,"Apríl",1
4921,"ViewTranslation","May [month]","",,"",2593,"Maí",1
4922,"ViewTranslation","June [month]","",,"",2593,"Júní",1
4923,"ViewTranslation","July [month]","",,"",2593,"Júlí",1
4924,"ViewTranslation","August [month]","",,"",2593,"Ágúst",1
4925,"ViewTranslation","September [month]","",,"",2593,"September",1
4926,"ViewTranslation","October [month]","",,"",2593,"Október",1
4927,"ViewTranslation","November [month]","",,"",2593,"Nóvember",1
4928,"ViewTranslation","December [month]","",,"",2593,"Desember",1
4929,"ViewTranslation","Jan [abbreviated month]","",,"",2593,"Jan",1
4930,"ViewTranslation","Feb [abbreviated month]","",,"",2593,"Feb",1
4931,"ViewTranslation","Mar [abbreviated month]","",,"",2593,"Mar",1
4932,"ViewTranslation","Apr [abbreviated month]","",,"",2593,"Apr",1
4933,"ViewTranslation","May [abbreviated month]","",,"",2593,"Maí",1
4934,"ViewTranslation","Jun [abbreviated month]","",,"",2593,"Jún",1
4935,"ViewTranslation","Jul [abbreviated month]","",,"",2593,"Júl",1
4936,"ViewTranslation","Aug [abbreviated month]","",,"",2593,"Ágú",1
4937,"ViewTranslation","Sep [abbreviated month]","",,"",2593,"Sep",1
4938,"ViewTranslation","Oct [abbreviated month]","",,"",2593,"Okt",1
4939,"ViewTranslation","Nov [abbreviated month]","",,"",2593,"Nóv",1
4940,"ViewTranslation","Dec [abbreviated month]","",,"",2593,"Des",1
4941,"ViewTranslation","Sunday [weekday]","",,"",2600,"Domenica",1
4942,"ViewTranslation","Monday [weekday]","",,"",2600,"Lunedì",1
4943,"ViewTranslation","Tuesday [weekday]","",,"",2600,"Martedì",1
4944,"ViewTranslation","Wednesday [weekday]","",,"",2600,"Mercoledì",1
4945,"ViewTranslation","Thursday [weekday]","",,"",2600,"Giovedì",1
4946,"ViewTranslation","Friday [weekday]","",,"",2600,"Venerdì",1
4947,"ViewTranslation","Saturday [weekday]","",,"",2600,"Sabato",1
4948,"ViewTranslation","Sun [abbreviated weekday]","",,"",2600,"Dom",1
4949,"ViewTranslation","Mon [abbreviated weekday]","",,"",2600,"Lun",1
4950,"ViewTranslation","Tue [abbreviated weekday]","",,"",2600,"Mar",1
4951,"ViewTranslation","Wed [abbreviated weekday]","",,"",2600,"Mer",1
4952,"ViewTranslation","Thu [abbreviated weekday]","",,"",2600,"Gio",1
4953,"ViewTranslation","Fri [abbreviated weekday]","",,"",2600,"Ven",1
4954,"ViewTranslation","Sat [abbreviated weekday]","",,"",2600,"Sab",1
4955,"ViewTranslation","January [month]","",,"",2600,"Gennaio",1
4956,"ViewTranslation","February [month]","",,"",2600,"Febbraio",1
4957,"ViewTranslation","March [month]","",,"",2600,"Marzo",1
4958,"ViewTranslation","April [month]","",,"",2600,"Aprile",1
4959,"ViewTranslation","May [month]","",,"",2600,"Maggio",1
4960,"ViewTranslation","June [month]","",,"",2600,"Giugno",1
4961,"ViewTranslation","July [month]","",,"",2600,"Luglio",1
4962,"ViewTranslation","August [month]","",,"",2600,"Agosto",1
4963,"ViewTranslation","September [month]","",,"",2600,"Settembre",1
4964,"ViewTranslation","October [month]","",,"",2600,"Ottobre",1
4965,"ViewTranslation","November [month]","",,"",2600,"Novembre",1
4966,"ViewTranslation","December [month]","",,"",2600,"Dicembre",1
4967,"ViewTranslation","Jan [abbreviated month]","",,"",2600,"Gen",1
4968,"ViewTranslation","Feb [abbreviated month]","",,"",2600,"Feb",1
4969,"ViewTranslation","Mar [abbreviated month]","",,"",2600,"Mar",1
4970,"ViewTranslation","Apr [abbreviated month]","",,"",2600,"Apr",1
4971,"ViewTranslation","May [abbreviated month]","",,"",2600,"Mag",1
4972,"ViewTranslation","Jun [abbreviated month]","",,"",2600,"Giu",1
4973,"ViewTranslation","Jul [abbreviated month]","",,"",2600,"Lug",1
4974,"ViewTranslation","Aug [abbreviated month]","",,"",2600,"Ago",1
4975,"ViewTranslation","Sep [abbreviated month]","",,"",2600,"Set",1
4976,"ViewTranslation","Oct [abbreviated month]","",,"",2600,"Ott",1
4977,"ViewTranslation","Nov [abbreviated month]","",,"",2600,"Nov",1
4978,"ViewTranslation","Dec [abbreviated month]","",,"",2600,"Dic",1
4979,"ViewTranslation","Sunday [weekday]","",,"",2723,"日曜日",1
4980,"ViewTranslation","Monday [weekday]","",,"",2723,"月曜日",1
4981,"ViewTranslation","Tuesday [weekday]","",,"",2723,"火曜日",1
4982,"ViewTranslation","Wednesday [weekday]","",,"",2723,"水曜日",1
4983,"ViewTranslation","Thursday [weekday]","",,"",2723,"木曜日",1
4984,"ViewTranslation","Friday [weekday]","",,"",2723,"金曜日",1
4985,"ViewTranslation","Saturday [weekday]","",,"",2723,"土曜日",1
4986,"ViewTranslation","Sun [abbreviated weekday]","",,"",2723,"日",1
4987,"ViewTranslation","Mon [abbreviated weekday]","",,"",2723,"月",1
4988,"ViewTranslation","Tue [abbreviated weekday]","",,"",2723,"火",1
4989,"ViewTranslation","Wed [abbreviated weekday]","",,"",2723,"水",1
4990,"ViewTranslation","Thu [abbreviated weekday]","",,"",2723,"木",1
4991,"ViewTranslation","Fri [abbreviated weekday]","",,"",2723,"金",1
4992,"ViewTranslation","Sat [abbreviated weekday]","",,"",2723,"土",1
4993,"ViewTranslation","January [month]","",,"",2723,"1月",1
4994,"ViewTranslation","February [month]","",,"",2723,"2月",1
4995,"ViewTranslation","March [month]","",,"",2723,"3月",1
4996,"ViewTranslation","April [month]","",,"",2723,"4月",1
4997,"ViewTranslation","May [month]","",,"",2723,"5月",1
4998,"ViewTranslation","June [month]","",,"",2723,"6月",1
4999,"ViewTranslation","July [month]","",,"",2723,"7月",1
5000,"ViewTranslation","August [month]","",,"",2723,"8月",1
5001,"ViewTranslation","September [month]","",,"",2723,"9月",1
5002,"ViewTranslation","October [month]","",,"",2723,"10月",1
5003,"ViewTranslation","November [month]","",,"",2723,"11月",1
5004,"ViewTranslation","December [month]","",,"",2723,"12月",1
5005,"ViewTranslation","Jan [abbreviated month]","",,"",2723," 1月",1
5006,"ViewTranslation","Feb [abbreviated month]","",,"",2723," 2月",1
5007,"ViewTranslation","Mar [abbreviated month]","",,"",2723," 3月",1
5008,"ViewTranslation","Apr [abbreviated month]","",,"",2723," 4月",1
5009,"ViewTranslation","May [abbreviated month]","",,"",2723," 5月",1
5010,"ViewTranslation","Jun [abbreviated month]","",,"",2723," 6月",1
5011,"ViewTranslation","Jul [abbreviated month]","",,"",2723," 7月",1
5012,"ViewTranslation","Aug [abbreviated month]","",,"",2723," 8月",1
5013,"ViewTranslation","Sep [abbreviated month]","",,"",2723," 9月",1
5014,"ViewTranslation","Oct [abbreviated month]","",,"",2723,"10月",1
5015,"ViewTranslation","Nov [abbreviated month]","",,"",2723,"11月",1
5016,"ViewTranslation","Dec [abbreviated month]","",,"",2723,"12月",1
5017,"ViewTranslation","Sunday [weekday]","",,"",2770,"კვირა",1
5018,"ViewTranslation","Monday [weekday]","",,"",2770,"ორშაბათი",1
5019,"ViewTranslation","Tuesday [weekday]","",,"",2770,"სამშაბათი",1
5020,"ViewTranslation","Wednesday [weekday]","",,"",2770,"ოთხშაბათი",1
5021,"ViewTranslation","Thursday [weekday]","",,"",2770,"ხუთშაბათი",1
5022,"ViewTranslation","Friday [weekday]","",,"",2770,"პარასკევი",1
5023,"ViewTranslation","Saturday [weekday]","",,"",2770,"შაბათი",1
5024,"ViewTranslation","Sun [abbreviated weekday]","",,"",2770,"კვი",1
5025,"ViewTranslation","Mon [abbreviated weekday]","",,"",2770,"ორშ",1
5026,"ViewTranslation","Tue [abbreviated weekday]","",,"",2770,"სამ",1
5027,"ViewTranslation","Wed [abbreviated weekday]","",,"",2770,"ოთხ",1
5028,"ViewTranslation","Thu [abbreviated weekday]","",,"",2770,"ხუთ",1
5029,"ViewTranslation","Fri [abbreviated weekday]","",,"",2770,"პარ",1
5030,"ViewTranslation","Sat [abbreviated weekday]","",,"",2770,"შაბ",1
5031,"ViewTranslation","January [month]","",,"",2770,"იანვარი",1
5032,"ViewTranslation","February [month]","",,"",2770,"თებერვალი",1
5033,"ViewTranslation","March [month]","",,"",2770,"მარტი",1
5034,"ViewTranslation","April [month]","",,"",2770,"აპრილი",1
5035,"ViewTranslation","May [month]","",,"",2770,"მაისი",1
5036,"ViewTranslation","June [month]","",,"",2770,"ივნისი",1
5037,"ViewTranslation","July [month]","",,"",2770,"ივლისი",1
5038,"ViewTranslation","August [month]","",,"",2770,"აგვისტო",1
5039,"ViewTranslation","September [month]","",,"",2770,"სექტემბერი",1
5040,"ViewTranslation","October [month]","",,"",2770,"ოქტომბერი",1
5041,"ViewTranslation","November [month]","",,"",2770,"ნოემბერი",1
5042,"ViewTranslation","December [month]","",,"",2770,"დეკემბერი",1
5043,"ViewTranslation","Jan [abbreviated month]","",,"",2770,"იან",1
5044,"ViewTranslation","Feb [abbreviated month]","",,"",2770,"თებ",1
5045,"ViewTranslation","Mar [abbreviated month]","",,"",2770,"მარ",1
5046,"ViewTranslation","Apr [abbreviated month]","",,"",2770,"აპრ",1
5047,"ViewTranslation","May [abbreviated month]","",,"",2770,"მაი",1
5048,"ViewTranslation","Jun [abbreviated month]","",,"",2770,"ივნ",1
5049,"ViewTranslation","Jul [abbreviated month]","",,"",2770,"ივლ",1
5050,"ViewTranslation","Aug [abbreviated month]","",,"",2770,"აგვ",1
5051,"ViewTranslation","Sep [abbreviated month]","",,"",2770,"სექ",1
5052,"ViewTranslation","Oct [abbreviated month]","",,"",2770,"ოქტ",1
5053,"ViewTranslation","Nov [abbreviated month]","",,"",2770,"ნოე",1
5054,"ViewTranslation","Dec [abbreviated month]","",,"",2770,"დეკ",1
5055,"ViewTranslation","Sunday [weekday]","",,"",2763,"Sabaat",1
5056,"ViewTranslation","Monday [weekday]","",,"",2763,"Ataasinngorneq",1
5057,"ViewTranslation","Tuesday [weekday]","",,"",2763,"Marlunngorneq",1
5058,"ViewTranslation","Wednesday [weekday]","",,"",2763,"Pingasunngorneq",1
5059,"ViewTranslation","Thursday [weekday]","",,"",2763,"Sisamanngorneq",1
5060,"ViewTranslation","Friday [weekday]","",,"",2763,"Tallimanngorneq",1
5061,"ViewTranslation","Saturday [weekday]","",,"",2763,"Arfininngorneq",1
5062,"ViewTranslation","Sun [abbreviated weekday]","",,"",2763,"Sab",1
5063,"ViewTranslation","Mon [abbreviated weekday]","",,"",2763,"Ata",1
5064,"ViewTranslation","Tue [abbreviated weekday]","",,"",2763,"Mar",1
5065,"ViewTranslation","Wed [abbreviated weekday]","",,"",2763,"Pin",1
5066,"ViewTranslation","Thu [abbreviated weekday]","",,"",2763,"Sis",1
5067,"ViewTranslation","Fri [abbreviated weekday]","",,"",2763,"Tal",1
5068,"ViewTranslation","Sat [abbreviated weekday]","",,"",2763,"Arf",1
5069,"ViewTranslation","January [month]","",,"",2763,"Januari",1
5070,"ViewTranslation","February [month]","",,"",2763,"Februari",1
5071,"ViewTranslation","March [month]","",,"",2763,"Martsi",1
5072,"ViewTranslation","April [month]","",,"",2763,"Aprili",1
5073,"ViewTranslation","May [month]","",,"",2763,"Maji",1
5074,"ViewTranslation","June [month]","",,"",2763,"Juni",1
5075,"ViewTranslation","July [month]","",,"",2763,"Juli",1
5076,"ViewTranslation","August [month]","",,"",2763,"Augustusi",1
5077,"ViewTranslation","September [month]","",,"",2763,"Septemberi",1
5078,"ViewTranslation","October [month]","",,"",2763,"Oktoberi",1
5079,"ViewTranslation","November [month]","",,"",2763,"Novemberi",1
5080,"ViewTranslation","December [month]","",,"",2763,"Decemberi",1
5081,"ViewTranslation","Jan [abbreviated month]","",,"",2763,"Jan",1
5082,"ViewTranslation","Feb [abbreviated month]","",,"",2763,"Feb",1
5083,"ViewTranslation","Mar [abbreviated month]","",,"",2763,"Mar",1
5084,"ViewTranslation","Apr [abbreviated month]","",,"",2763,"Apr",1
5085,"ViewTranslation","May [abbreviated month]","",,"",2763,"Maj",1
5086,"ViewTranslation","Jun [abbreviated month]","",,"",2763,"Jun",1
5087,"ViewTranslation","Jul [abbreviated month]","",,"",2763,"Jul",1
5088,"ViewTranslation","Aug [abbreviated month]","",,"",2763,"Aug",1
5089,"ViewTranslation","Sep [abbreviated month]","",,"",2763,"Sep",1
5090,"ViewTranslation","Oct [abbreviated month]","",,"",2763,"Okt",1
5091,"ViewTranslation","Nov [abbreviated month]","",,"",2763,"Nov",1
5092,"ViewTranslation","Dec [abbreviated month]","",,"",2763,"Dec",1
5093,"ViewTranslation","Sunday [weekday]","",,"",2765,"ರವಿವಾರ",1
5094,"ViewTranslation","Monday [weekday]","",,"",2765,"ಸೋಮವಾರ",1
5095,"ViewTranslation","Tuesday [weekday]","",,"",2765,"ಮಂಗಳವಾರ",1
5096,"ViewTranslation","Wednesday [weekday]","",,"",2765,"ಬುಧವಾರ",1
5097,"ViewTranslation","Thursday [weekday]","",,"",2765,"ಗುರುವಾರ",1
5098,"ViewTranslation","Friday [weekday]","",,"",2765,"ಶುಕ್ರವಾರ",1
5099,"ViewTranslation","Saturday [weekday]","",,"",2765,"ಶನಿವಾರ",1
5100,"ViewTranslation","Sun [abbreviated weekday]","",,"",2765,"ರ",1
5101,"ViewTranslation","Mon [abbreviated weekday]","",,"",2765,"ಸೋ",1
5102,"ViewTranslation","Tue [abbreviated weekday]","",,"",2765,"ಮಂ",1
5103,"ViewTranslation","Wed [abbreviated weekday]","",,"",2765,"ಬು",1
5104,"ViewTranslation","Thu [abbreviated weekday]","",,"",2765,"ಗು",1
5105,"ViewTranslation","Fri [abbreviated weekday]","",,"",2765,"ಶು",1
5106,"ViewTranslation","Sat [abbreviated weekday]","",,"",2765,"ಶ",1
5107,"ViewTranslation","January [month]","",,"",2765,"ಜನವರಿ",1
5108,"ViewTranslation","February [month]","",,"",2765,"ಫೆಬ್ರವರಿ",1
5109,"ViewTranslation","March [month]","",,"",2765,"ಮಾರ್ಚ",1
5110,"ViewTranslation","April [month]","",,"",2765,"ಏಪ್ರಿಲ್",1
5111,"ViewTranslation","May [month]","",,"",2765,"ಮೇ",1
5112,"ViewTranslation","June [month]","",,"",2765,"ಜೂನ್",1
5113,"ViewTranslation","July [month]","",,"",2765,"ಜುಲಾಯಿ",1
5114,"ViewTranslation","August [month]","",,"",2765,"ಆಗಸ್ತು",1
5115,"ViewTranslation","September [month]","",,"",2765,"ಸೆಪ್ಟೆಂಬರ",1
5116,"ViewTranslation","October [month]","",,"",2765,"ಅಕ್ತೂಬರ",1
5117,"ViewTranslation","November [month]","",,"",2765,"ನವೆಂಬರ",1
5118,"ViewTranslation","December [month]","",,"",2765,"ದಶಂಬರ",1
5119,"ViewTranslation","Jan [abbreviated month]","",,"",2765,"ಜ",1
5120,"ViewTranslation","Feb [abbreviated month]","",,"",2765,"ಫೆ",1
5121,"ViewTranslation","Mar [abbreviated month]","",,"",2765,"ಮಾ",1
5122,"ViewTranslation","Apr [abbreviated month]","",,"",2765,"ಏ",1
5123,"ViewTranslation","May [abbreviated month]","",,"",2765,"ಮೇ",1
5124,"ViewTranslation","Jun [abbreviated month]","",,"",2765,"ಜೂ",1
5125,"ViewTranslation","Jul [abbreviated month]","",,"",2765,"ಜು",1
5126,"ViewTranslation","Aug [abbreviated month]","",,"",2765,"ಆ",1
5127,"ViewTranslation","Sep [abbreviated month]","",,"",2765,"ಸೆ",1
5128,"ViewTranslation","Oct [abbreviated month]","",,"",2765,"ಅ",1
5129,"ViewTranslation","Nov [abbreviated month]","",,"",2765,"ನ",1
5130,"ViewTranslation","Dec [abbreviated month]","",,"",2765,"ದ",1
5131,"ViewTranslation","Sunday [weekday]","",,"",3122,"일요일",1
5132,"ViewTranslation","Monday [weekday]","",,"",3122,"월요일",1
5133,"ViewTranslation","Tuesday [weekday]","",,"",3122,"화요일",1
5134,"ViewTranslation","Wednesday [weekday]","",,"",3122,"수요일",1
5135,"ViewTranslation","Thursday [weekday]","",,"",3122,"목요일",1
5136,"ViewTranslation","Friday [weekday]","",,"",3122,"금요일",1
5137,"ViewTranslation","Saturday [weekday]","",,"",3122,"토요일",1
5138,"ViewTranslation","Sun [abbreviated weekday]","",,"",3122,"일",1
5139,"ViewTranslation","Mon [abbreviated weekday]","",,"",3122,"월",1
5140,"ViewTranslation","Tue [abbreviated weekday]","",,"",3122,"화",1
5141,"ViewTranslation","Wed [abbreviated weekday]","",,"",3122,"수",1
5142,"ViewTranslation","Thu [abbreviated weekday]","",,"",3122,"목",1
5143,"ViewTranslation","Fri [abbreviated weekday]","",,"",3122,"금",1
5144,"ViewTranslation","Sat [abbreviated weekday]","",,"",3122,"토",1
5145,"ViewTranslation","January [month]","",,"",3122,"일월",1
5146,"ViewTranslation","February [month]","",,"",3122,"이월",1
5147,"ViewTranslation","March [month]","",,"",3122,"삼월",1
5148,"ViewTranslation","April [month]","",,"",3122,"사월",1
5149,"ViewTranslation","May [month]","",,"",3122,"오월",1
5150,"ViewTranslation","June [month]","",,"",3122,"유월",1
5151,"ViewTranslation","July [month]","",,"",3122,"칠월",1
5152,"ViewTranslation","August [month]","",,"",3122,"팔월",1
5153,"ViewTranslation","September [month]","",,"",3122,"구월",1
5154,"ViewTranslation","October [month]","",,"",3122,"시월",1
5155,"ViewTranslation","November [month]","",,"",3122,"십일월",1
5156,"ViewTranslation","December [month]","",,"",3122,"십이월",1
5157,"ViewTranslation","Jan [abbreviated month]","",,"",3122," 1월",1
5158,"ViewTranslation","Feb [abbreviated month]","",,"",3122," 2월",1
5159,"ViewTranslation","Mar [abbreviated month]","",,"",3122," 3월",1
5160,"ViewTranslation","Apr [abbreviated month]","",,"",3122," 4월",1
5161,"ViewTranslation","May [abbreviated month]","",,"",3122," 5월",1
5162,"ViewTranslation","Jun [abbreviated month]","",,"",3122," 6월",1
5163,"ViewTranslation","Jul [abbreviated month]","",,"",3122," 7월",1
5164,"ViewTranslation","Aug [abbreviated month]","",,"",3122," 8월",1
5165,"ViewTranslation","Sep [abbreviated month]","",,"",3122," 9월",1
5166,"ViewTranslation","Oct [abbreviated month]","",,"",3122,"10월",1
5167,"ViewTranslation","Nov [abbreviated month]","",,"",3122,"11월",1
5168,"ViewTranslation","Dec [abbreviated month]","",,"",3122,"12월",1
5169,"ViewTranslation","Sunday [weekday]","",,"",1372,"De sul",1
5170,"ViewTranslation","Monday [weekday]","",,"",1372,"De lun",1
5171,"ViewTranslation","Tuesday [weekday]","",,"",1372,"De merth",1
5172,"ViewTranslation","Wednesday [weekday]","",,"",1372,"De merher",1
5173,"ViewTranslation","Thursday [weekday]","",,"",1372,"De yow",1
5174,"ViewTranslation","Friday [weekday]","",,"",1372,"De gwener",1
5175,"ViewTranslation","Saturday [weekday]","",,"",1372,"De sadorn",1
5176,"ViewTranslation","Sun [abbreviated weekday]","",,"",1372,"Sul",1
5177,"ViewTranslation","Mon [abbreviated weekday]","",,"",1372,"Lun",1
5178,"ViewTranslation","Tue [abbreviated weekday]","",,"",1372,"Mth",1
5179,"ViewTranslation","Wed [abbreviated weekday]","",,"",1372,"Mhr",1
5180,"ViewTranslation","Thu [abbreviated weekday]","",,"",1372,"Yow",1
5181,"ViewTranslation","Fri [abbreviated weekday]","",,"",1372,"Gwe",1
5182,"ViewTranslation","Sat [abbreviated weekday]","",,"",1372,"Sad",1
5183,"ViewTranslation","January [month]","",,"",1372,"Mys genver",1
5184,"ViewTranslation","February [month]","",,"",1372,"Mys whevrel",1
5185,"ViewTranslation","March [month]","",,"",1372,"Mys merth",1
5186,"ViewTranslation","April [month]","",,"",1372,"Mys ebrel",1
5187,"ViewTranslation","May [month]","",,"",1372,"Mys me",1
5188,"ViewTranslation","June [month]","",,"",1372,"Mys evan",1
5189,"ViewTranslation","July [month]","",,"",1372,"Mys gortheren",1
5190,"ViewTranslation","August [month]","",,"",1372,"Mye est",1
5191,"ViewTranslation","September [month]","",,"",1372,"Mys gwyngala",1
5192,"ViewTranslation","October [month]","",,"",1372,"Mys hedra",1
5193,"ViewTranslation","November [month]","",,"",1372,"Mys du",1
5194,"ViewTranslation","December [month]","",,"",1372,"Mys kevardhu",1
5195,"ViewTranslation","Jan [abbreviated month]","",,"",1372,"Gen",1
5196,"ViewTranslation","Feb [abbreviated month]","",,"",1372,"Whe>",1
5197,"ViewTranslation","Mar [abbreviated month]","",,"",1372,"Mer",1
5198,"ViewTranslation","Apr [abbreviated month]","",,"",1372,"Ebr",1
5199,"ViewTranslation","May [abbreviated month]","",,"",1372,"Me",1
5200,"ViewTranslation","Jun [abbreviated month]","",,"",1372,"Evn",1
5201,"ViewTranslation","Jul [abbreviated month]","",,"",1372,"Gor",1
5202,"ViewTranslation","Aug [abbreviated month]","",,"",1372,"Est",1
5203,"ViewTranslation","Sep [abbreviated month]","",,"",1372,"Gwn",1
5204,"ViewTranslation","Oct [abbreviated month]","",,"",1372,"Hed",1
5205,"ViewTranslation","Nov [abbreviated month]","",,"",1372,"Du",1
5206,"ViewTranslation","Dec [abbreviated month]","",,"",1372,"Kev",1
5207,"ViewTranslation","Sunday [weekday]","",,"",3694,"Sabiiti",1
5208,"ViewTranslation","Monday [weekday]","",,"",3694,"Balaza",1
5209,"ViewTranslation","Tuesday [weekday]","",,"",3694,"Lwakubiri",1
5210,"ViewTranslation","Wednesday [weekday]","",,"",3694,"Lwakusatu",1
5211,"ViewTranslation","Thursday [weekday]","",,"",3694,"Lwakuna",1
5212,"ViewTranslation","Friday [weekday]","",,"",3694,"Lwakutaano",1
5213,"ViewTranslation","Saturday [weekday]","",,"",3694,"Lwamukaaga",1
5214,"ViewTranslation","Sun [abbreviated weekday]","",,"",3694,"Sab",1
5215,"ViewTranslation","Mon [abbreviated weekday]","",,"",3694,"Bal",1
5216,"ViewTranslation","Tue [abbreviated weekday]","",,"",3694,"Lw2",1
5217,"ViewTranslation","Wed [abbreviated weekday]","",,"",3694,"Lw3",1
5218,"ViewTranslation","Thu [abbreviated weekday]","",,"",3694,"Lw4",1
5219,"ViewTranslation","Fri [abbreviated weekday]","",,"",3694,"Lw5",1
5220,"ViewTranslation","Sat [abbreviated weekday]","",,"",3694,"Lw6",1
5221,"ViewTranslation","January [month]","",,"",3694,"Janwaliyo",1
5222,"ViewTranslation","February [month]","",,"",3694,"Febwaliyo",1
5223,"ViewTranslation","March [month]","",,"",3694,"Marisi",1
5224,"ViewTranslation","April [month]","",,"",3694,"Apuli",1
5225,"ViewTranslation","May [month]","",,"",3694,"Maayi",1
5226,"ViewTranslation","June [month]","",,"",3694,"Juuni",1
5227,"ViewTranslation","July [month]","",,"",3694,"Julaai",1
5228,"ViewTranslation","August [month]","",,"",3694,"Agusito",1
5229,"ViewTranslation","September [month]","",,"",3694,"Sebuttemba",1
5230,"ViewTranslation","October [month]","",,"",3694,"Okitobba",1
5231,"ViewTranslation","November [month]","",,"",3694,"Novemba",1
5232,"ViewTranslation","December [month]","",,"",3694,"Desemba",1
5233,"ViewTranslation","Jan [abbreviated month]","",,"",3694,"Jan",1
5234,"ViewTranslation","Feb [abbreviated month]","",,"",3694,"Feb",1
5235,"ViewTranslation","Mar [abbreviated month]","",,"",3694,"Mar",1
5236,"ViewTranslation","Apr [abbreviated month]","",,"",3694,"Apu",1
5237,"ViewTranslation","May [abbreviated month]","",,"",3694,"Maa",1
5238,"ViewTranslation","Jun [abbreviated month]","",,"",3694,"Jun",1
5239,"ViewTranslation","Jul [abbreviated month]","",,"",3694,"Jul",1
5240,"ViewTranslation","Aug [abbreviated month]","",,"",3694,"Agu",1
5241,"ViewTranslation","Sep [abbreviated month]","",,"",3694,"Seb",1
5242,"ViewTranslation","Oct [abbreviated month]","",,"",3694,"Oki",1
5243,"ViewTranslation","Nov [abbreviated month]","",,"",3694,"Nov",1
5244,"ViewTranslation","Dec [abbreviated month]","",,"",3694,"Des",1
5245,"ViewTranslation","Sunday [weekday]","",,"",3428,"ອາທິດ",1
5246,"ViewTranslation","Monday [weekday]","",,"",3428,"ຈັນ",1
5247,"ViewTranslation","Tuesday [weekday]","",,"",3428,"ອັງຄານ",1
5248,"ViewTranslation","Wednesday [weekday]","",,"",3428,"ພຸດ",1
5249,"ViewTranslation","Thursday [weekday]","",,"",3428,"ພະຫັດ",1
5250,"ViewTranslation","Friday [weekday]","",,"",3428,"ສຸກ",1
5251,"ViewTranslation","Saturday [weekday]","",,"",3428,"ເສົາ",1
5252,"ViewTranslation","Sun [abbreviated weekday]","",,"",3428,"ອາ.",1
5253,"ViewTranslation","Mon [abbreviated weekday]","",,"",3428,"ຈ.",1
5254,"ViewTranslation","Tue [abbreviated weekday]","",,"",3428,"ຄ.",1
5255,"ViewTranslation","Wed [abbreviated weekday]","",,"",3428,"ພ.",1
5256,"ViewTranslation","Thu [abbreviated weekday]","",,"",3428,"ພຫ.",1
5257,"ViewTranslation","Fri [abbreviated weekday]","",,"",3428,"ສ.",1
5258,"ViewTranslation","Sat [abbreviated weekday]","",,"",3428,"ສ.",1
5259,"ViewTranslation","January [month]","",,"",3428,"ມັງກອນ",1
5260,"ViewTranslation","February [month]","",,"",3428,"ກຸມຟາ",1
5261,"ViewTranslation","March [month]","",,"",3428,"ມີນາ",1
5262,"ViewTranslation","April [month]","",,"",3428,"ເມສາ",1
5263,"ViewTranslation","May [month]","",,"",3428,"ພຶດສະພາ",1
5264,"ViewTranslation","June [month]","",,"",3428,"ມິຖຸນາ",1
5265,"ViewTranslation","July [month]","",,"",3428,"ກໍລະກົດ",1
5266,"ViewTranslation","August [month]","",,"",3428,"ສິງຫາ",1
5267,"ViewTranslation","September [month]","",,"",3428,"ກັນຍາ",1
5268,"ViewTranslation","October [month]","",,"",3428,"ຕຸລາ",1
5269,"ViewTranslation","November [month]","",,"",3428,"ພະຈິກ",1
5270,"ViewTranslation","December [month]","",,"",3428,"ທັນວາ",1
5271,"ViewTranslation","Jan [abbreviated month]","",,"",3428,"ມ.ກ.",1
5272,"ViewTranslation","Feb [abbreviated month]","",,"",3428,"ກ.ພ.",1
5273,"ViewTranslation","Mar [abbreviated month]","",,"",3428,"ມ.ນ.",1
5274,"ViewTranslation","Apr [abbreviated month]","",,"",3428,"ມ.ສ.",1
5275,"ViewTranslation","May [abbreviated month]","",,"",3428,"ພ.ພ.",1
5276,"ViewTranslation","Jun [abbreviated month]","",,"",3428,"ມິ.ຖ.",1
5277,"ViewTranslation","Jul [abbreviated month]","",,"",3428,"ກ.ລ.",1
5278,"ViewTranslation","Aug [abbreviated month]","",,"",3428,"ສ.ຫ.",1
5279,"ViewTranslation","Sep [abbreviated month]","",,"",3428,"ກ.ຍ.",1
5280,"ViewTranslation","Oct [abbreviated month]","",,"",3428,"ຕ.ລ.",1
5281,"ViewTranslation","Nov [abbreviated month]","",,"",3428,"ພ.ຈ.",1
5282,"ViewTranslation","Dec [abbreviated month]","",,"",3428,"ທ.ວ.",1
5283,"ViewTranslation","Sunday [weekday]","",,"",3553,"Sekmadienis",1
5284,"ViewTranslation","Monday [weekday]","",,"",3553,"Pirmadienis",1
5285,"ViewTranslation","Tuesday [weekday]","",,"",3553,"Antradienis",1
5286,"ViewTranslation","Wednesday [weekday]","",,"",3553,"Trečiadienis",1
5287,"ViewTranslation","Thursday [weekday]","",,"",3553,"Ketvirtadienis",1
5288,"ViewTranslation","Friday [weekday]","",,"",3553,"Penktadienis",1
5289,"ViewTranslation","Saturday [weekday]","",,"",3553,"Šeštadienis",1
5290,"ViewTranslation","Sun [abbreviated weekday]","",,"",3553,"Sk",1
5291,"ViewTranslation","Mon [abbreviated weekday]","",,"",3553,"Pr",1
5292,"ViewTranslation","Tue [abbreviated weekday]","",,"",3553,"An",1
5293,"ViewTranslation","Wed [abbreviated weekday]","",,"",3553,"Tr",1
5294,"ViewTranslation","Thu [abbreviated weekday]","",,"",3553,"Kt",1
5295,"ViewTranslation","Fri [abbreviated weekday]","",,"",3553,"Pn",1
5296,"ViewTranslation","Sat [abbreviated weekday]","",,"",3553,"Št",1
5297,"ViewTranslation","January [month]","",,"",3553,"Sausio",1
5298,"ViewTranslation","February [month]","",,"",3553,"Vasario",1
5299,"ViewTranslation","March [month]","",,"",3553,"Kovo",1
5300,"ViewTranslation","April [month]","",,"",3553,"Balandžio",1
5301,"ViewTranslation","May [month]","",,"",3553,"Gegužės",1
5302,"ViewTranslation","June [month]","",,"",3553,"Birželio",1
5303,"ViewTranslation","July [month]","",,"",3553,"Liepos",1
5304,"ViewTranslation","August [month]","",,"",3553,"Rugpjūčio",1
5305,"ViewTranslation","September [month]","",,"",3553,"Rugsėjo",1
5306,"ViewTranslation","October [month]","",,"",3553,"Spalio",1
5307,"ViewTranslation","November [month]","",,"",3553,"Lapkričio",1
5308,"ViewTranslation","December [month]","",,"",3553,"Gruodžio",1
5309,"ViewTranslation","Jan [abbreviated month]","",,"",3553,"Sau",1
5310,"ViewTranslation","Feb [abbreviated month]","",,"",3553,"Vas",1
5311,"ViewTranslation","Mar [abbreviated month]","",,"",3553,"Kov",1
5312,"ViewTranslation","Apr [abbreviated month]","",,"",3553,"Bal",1
5313,"ViewTranslation","May [abbreviated month]","",,"",3553,"Geg",1
5314,"ViewTranslation","Jun [abbreviated month]","",,"",3553,"Bir",1
5315,"ViewTranslation","Jul [abbreviated month]","",,"",3553,"Lie",1
5316,"ViewTranslation","Aug [abbreviated month]","",,"",3553,"Rgp",1
5317,"ViewTranslation","Sep [abbreviated month]","",,"",3553,"Rgs",1
5318,"ViewTranslation","Oct [abbreviated month]","",,"",3553,"Spa",1
5319,"ViewTranslation","Nov [abbreviated month]","",,"",3553,"Lap",1
5320,"ViewTranslation","Dec [abbreviated month]","",,"",3553,"Grd",1
5321,"ViewTranslation","Sunday [weekday]","",,"",3435,"Svētdiena",1
5322,"ViewTranslation","Monday [weekday]","",,"",3435,"Pirmdiena",1
5323,"ViewTranslation","Tuesday [weekday]","",,"",3435,"Otrdiena",1
5324,"ViewTranslation","Wednesday [weekday]","",,"",3435,"Trešdiena",1
5325,"ViewTranslation","Thursday [weekday]","",,"",3435,"Ceturtdiena",1
5326,"ViewTranslation","Friday [weekday]","",,"",3435,"Piektdiena",1
5327,"ViewTranslation","Saturday [weekday]","",,"",3435,"Sestdiena",1
5328,"ViewTranslation","Sun [abbreviated weekday]","",,"",3435,"Sv",1
5329,"ViewTranslation","Mon [abbreviated weekday]","",,"",3435,"P ",1
5330,"ViewTranslation","Tue [abbreviated weekday]","",,"",3435,"O ",1
5331,"ViewTranslation","Wed [abbreviated weekday]","",,"",3435,"T ",1
5332,"ViewTranslation","Thu [abbreviated weekday]","",,"",3435,"C ",1
5333,"ViewTranslation","Fri [abbreviated weekday]","",,"",3435,"Pk",1
5334,"ViewTranslation","Sat [abbreviated weekday]","",,"",3435,"S ",1
5335,"ViewTranslation","January [month]","",,"",3435,"Janvāris",1
5336,"ViewTranslation","February [month]","",,"",3435,"Februāris",1
5337,"ViewTranslation","March [month]","",,"",3435,"Marts",1
5338,"ViewTranslation","April [month]","",,"",3435,"Aprīlis",1
5339,"ViewTranslation","May [month]","",,"",3435,"Maijs",1
5340,"ViewTranslation","June [month]","",,"",3435,"Jūnijs",1
5341,"ViewTranslation","July [month]","",,"",3435,"Jūlijs",1
5342,"ViewTranslation","August [month]","",,"",3435,"Augusts",1
5343,"ViewTranslation","September [month]","",,"",3435,"Septembris",1
5344,"ViewTranslation","October [month]","",,"",3435,"Oktobris",1
5345,"ViewTranslation","November [month]","",,"",3435,"Novembris",1
5346,"ViewTranslation","December [month]","",,"",3435,"Decembris",1
5347,"ViewTranslation","Jan [abbreviated month]","",,"",3435,"Jan",1
5348,"ViewTranslation","Feb [abbreviated month]","",,"",3435,"Feb",1
5349,"ViewTranslation","Mar [abbreviated month]","",,"",3435,"Mar",1
5350,"ViewTranslation","Apr [abbreviated month]","",,"",3435,"Apr",1
5351,"ViewTranslation","May [abbreviated month]","",,"",3435,"Mai",1
5352,"ViewTranslation","Jun [abbreviated month]","",,"",3435,"Jūn",1
5353,"ViewTranslation","Jul [abbreviated month]","",,"",3435,"Jūl",1
5354,"ViewTranslation","Aug [abbreviated month]","",,"",3435,"Aug",1
5355,"ViewTranslation","Sep [abbreviated month]","",,"",3435,"Sep",1
5356,"ViewTranslation","Oct [abbreviated month]","",,"",3435,"Okt",1
5357,"ViewTranslation","Nov [abbreviated month]","",,"",3435,"Nov",1
5358,"ViewTranslation","Dec [abbreviated month]","",,"",3435,"Dec",1
5359,"ViewTranslation","Sunday [weekday]","",,"",4166,"Rātapu",1
5360,"ViewTranslation","Monday [weekday]","",,"",4166,"Mane",1
5361,"ViewTranslation","Tuesday [weekday]","",,"",4166,"Tūrei",1
5362,"ViewTranslation","Wednesday [weekday]","",,"",4166,"Wenerei",1
5363,"ViewTranslation","Thursday [weekday]","",,"",4166,"Tāite",1
5364,"ViewTranslation","Friday [weekday]","",,"",4166,"Paraire",1
5365,"ViewTranslation","Saturday [weekday]","",,"",4166,"Hātarei",1
5366,"ViewTranslation","Sun [abbreviated weekday]","",,"",4166,"Ta",1
5367,"ViewTranslation","Mon [abbreviated weekday]","",,"",4166,"Ma",1
5368,"ViewTranslation","Tue [abbreviated weekday]","",,"",4166,"Tū",1
5369,"ViewTranslation","Wed [abbreviated weekday]","",,"",4166,"We",1
5370,"ViewTranslation","Thu [abbreviated weekday]","",,"",4166,"Tāi",1
5371,"ViewTranslation","Fri [abbreviated weekday]","",,"",4166,"Pa",1
5372,"ViewTranslation","Sat [abbreviated weekday]","",,"",4166,"Hā",1
5373,"ViewTranslation","January [month]","",,"",4166,"Kohi-tātea",1
5374,"ViewTranslation","February [month]","",,"",4166,"Hui-tanguru",1
5375,"ViewTranslation","March [month]","",,"",4166,"Poutū-te-rangi",1
5376,"ViewTranslation","April [month]","",,"",4166,"Paenga-whāwhā",1
5377,"ViewTranslation","May [month]","",,"",4166,"Haratua",1
5378,"ViewTranslation","June [month]","",,"",4166,"Pipiri",1
5379,"ViewTranslation","July [month]","",,"",4166,"Hōngoingoi",1
5380,"ViewTranslation","August [month]","",,"",4166,"Here-turi-kōkā",1
5381,"ViewTranslation","September [month]","",,"",4166,"Mahuru",1
5382,"ViewTranslation","October [month]","",,"",4166,"Whiringa-ā-nuku",1
5383,"ViewTranslation","November [month]","",,"",4166,"Whiringa-ā-rangi",1
5384,"ViewTranslation","December [month]","",,"",4166,"Hakihea",1
5385,"ViewTranslation","Jan [abbreviated month]","",,"",4166,"Kohi",1
5386,"ViewTranslation","Feb [abbreviated month]","",,"",4166,"Hui",1
5387,"ViewTranslation","Mar [abbreviated month]","",,"",4166,"Pou",1
5388,"ViewTranslation","Apr [abbreviated month]","",,"",4166,"Pae",1
5389,"ViewTranslation","May [abbreviated month]","",,"",4166,"Hara",1
5390,"ViewTranslation","Jun [abbreviated month]","",,"",4166,"Pipi",1
5391,"ViewTranslation","Jul [abbreviated month]","",,"",4166,"Hōngoi",1
5392,"ViewTranslation","Aug [abbreviated month]","",,"",4166,"Here",1
5393,"ViewTranslation","Sep [abbreviated month]","",,"",4166,"Mahu",1
5394,"ViewTranslation","Oct [abbreviated month]","",,"",4166,"Whi-nu",1
5395,"ViewTranslation","Nov [abbreviated month]","",,"",4166,"Whi-ra",1
5396,"ViewTranslation","Dec [abbreviated month]","",,"",4166,"Haki",1
5397,"ViewTranslation","Sunday [weekday]","",,"",3981,"Недела",1
5398,"ViewTranslation","Monday [weekday]","",,"",3981,"Понеделник",1
5399,"ViewTranslation","Tuesday [weekday]","",,"",3981,"Вторник",1
5400,"ViewTranslation","Wednesday [weekday]","",,"",3981,"Среда",1
5401,"ViewTranslation","Thursday [weekday]","",,"",3981,"Четврток",1
5402,"ViewTranslation","Friday [weekday]","",,"",3981,"Петок",1
5403,"ViewTranslation","Saturday [weekday]","",,"",3981,"Сабота",1
5404,"ViewTranslation","Sun [abbreviated weekday]","",,"",3981,"Нед",1
5405,"ViewTranslation","Mon [abbreviated weekday]","",,"",3981,"Пон",1
5406,"ViewTranslation","Tue [abbreviated weekday]","",,"",3981,"Вто",1
5407,"ViewTranslation","Wed [abbreviated weekday]","",,"",3981,"Сре",1
5408,"ViewTranslation","Thu [abbreviated weekday]","",,"",3981,"Чет",1
5409,"ViewTranslation","Fri [abbreviated weekday]","",,"",3981,"Пет",1
5410,"ViewTranslation","Sat [abbreviated weekday]","",,"",3981,"Саб",1
5411,"ViewTranslation","January [month]","",,"",3981,"Јануари",1
5412,"ViewTranslation","February [month]","",,"",3981,"Февруари",1
5413,"ViewTranslation","March [month]","",,"",3981,"Март",1
5414,"ViewTranslation","April [month]","",,"",3981,"Април",1
5415,"ViewTranslation","May [month]","",,"",3981,"Мај",1
5416,"ViewTranslation","June [month]","",,"",3981,"Јуни",1
5417,"ViewTranslation","July [month]","",,"",3981,"Јули",1
5418,"ViewTranslation","August [month]","",,"",3981,"Август",1
5419,"ViewTranslation","September [month]","",,"",3981,"Септември",1
5420,"ViewTranslation","October [month]","",,"",3981,"Октомври",1
5421,"ViewTranslation","November [month]","",,"",3981,"Ноември",1
5422,"ViewTranslation","December [month]","",,"",3981,"Декември",1
5423,"ViewTranslation","Jan [abbreviated month]","",,"",3981,"Јан",1
5424,"ViewTranslation","Feb [abbreviated month]","",,"",3981,"Фев",1
5425,"ViewTranslation","Mar [abbreviated month]","",,"",3981,"Мар",1
5426,"ViewTranslation","Apr [abbreviated month]","",,"",3981,"Апр",1
5427,"ViewTranslation","May [abbreviated month]","",,"",3981,"Мај",1
5428,"ViewTranslation","Jun [abbreviated month]","",,"",3981,"Јун",1
5429,"ViewTranslation","Jul [abbreviated month]","",,"",3981,"Јул",1
5430,"ViewTranslation","Aug [abbreviated month]","",,"",3981,"Авг",1
5431,"ViewTranslation","Sep [abbreviated month]","",,"",3981,"Сеп",1
5432,"ViewTranslation","Oct [abbreviated month]","",,"",3981,"Окт",1
5433,"ViewTranslation","Nov [abbreviated month]","",,"",3981,"Ное",1
5434,"ViewTranslation","Dec [abbreviated month]","",,"",3981,"Дек",1
5435,"ViewTranslation","Sunday [weekday]","",,"",3736,"ഞായറു്",1
5436,"ViewTranslation","Monday [weekday]","",,"",3736,"തിങ്കളു്",1
5437,"ViewTranslation","Tuesday [weekday]","",,"",3736,"ചൊവ്വ",1
5438,"ViewTranslation","Wednesday [weekday]","",,"",3736,"ബുധനു്",1
5439,"ViewTranslation","Thursday [weekday]","",,"",3736,"വ്യാഴം",1
5440,"ViewTranslation","Friday [weekday]","",,"",3736,"വെള്ളി",1
5441,"ViewTranslation","Saturday [weekday]","",,"",3736,"ശനി",1
5442,"ViewTranslation","Sun [abbreviated weekday]","",,"",3736,"ഞാ",1
5443,"ViewTranslation","Mon [abbreviated weekday]","",,"",3736,"തി",1
5444,"ViewTranslation","Tue [abbreviated weekday]","",,"",3736,"ചൊ",1
5445,"ViewTranslation","Wed [abbreviated weekday]","",,"",3736,"ബു",1
5446,"ViewTranslation","Thu [abbreviated weekday]","",,"",3736,"വ്യാ",1
5447,"ViewTranslation","Fri [abbreviated weekday]","",,"",3736,"വെ",1
5448,"ViewTranslation","Sat [abbreviated weekday]","",,"",3736,"ശ",1
5449,"ViewTranslation","January [month]","",,"",3736,"ജനുവരി",1
5450,"ViewTranslation","February [month]","",,"",3736,"ഫെബ്രുവരി",1
5451,"ViewTranslation","March [month]","",,"",3736,"മാറു്ച്ച്",1
5452,"ViewTranslation","April [month]","",,"",3736,"ഏപ്റിലു്",1
5453,"ViewTranslation","May [month]","",,"",3736,"മെയ്",1
5454,"ViewTranslation","June [month]","",,"",3736,"ജൂണു്",1
5455,"ViewTranslation","July [month]","",,"",3736,"ജൂലൈ",1
5456,"ViewTranslation","August [month]","",,"",3736,"ആഗസ്ത്",1
5457,"ViewTranslation","September [month]","",,"",3736,"സെപ്തംബറു്",1
5458,"ViewTranslation","October [month]","",,"",3736,"ഒക്ടോബറു്",1
5459,"ViewTranslation","November [month]","",,"",3736,"നവംബറു്",1
5460,"ViewTranslation","December [month]","",,"",3736,"ഡിസംബറു്",1
5461,"ViewTranslation","Jan [abbreviated month]","",,"",3736,"ജനു",1
5462,"ViewTranslation","Feb [abbreviated month]","",,"",3736,"ഫെബ്",1
5463,"ViewTranslation","Mar [abbreviated month]","",,"",3736,"മാറ്",1
5464,"ViewTranslation","Apr [abbreviated month]","",,"",3736,"ഏപ്റില്",1
5465,"ViewTranslation","May [abbreviated month]","",,"",3736,"െമയ്",1
5466,"ViewTranslation","Jun [abbreviated month]","",,"",3736,"ജൂണ്",1
5467,"ViewTranslation","Jul [abbreviated month]","",,"",3736,"ജൂൈല",1
5468,"ViewTranslation","Aug [abbreviated month]","",,"",3736,"ആഗ",1
5469,"ViewTranslation","Sep [abbreviated month]","",,"",3736,"െസപ്തം",1
5470,"ViewTranslation","Oct [abbreviated month]","",,"",3736,"ഒക്ൈട",1
5471,"ViewTranslation","Nov [abbreviated month]","",,"",3736,"നവം",1
5472,"ViewTranslation","Dec [abbreviated month]","",,"",3736,"ഡിസം",1
5473,"ViewTranslation","Sunday [weekday]","",,"",4093,"Ням",1
5474,"ViewTranslation","Monday [weekday]","",,"",4093,"Даваа",1
5475,"ViewTranslation","Tuesday [weekday]","",,"",4093,"Мягмар",1
5476,"ViewTranslation","Wednesday [weekday]","",,"",4093,"Лхагва",1
5477,"ViewTranslation","Thursday [weekday]","",,"",4093,"Пүрэв",1
5478,"ViewTranslation","Friday [weekday]","",,"",4093,"Баасан",1
5479,"ViewTranslation","Saturday [weekday]","",,"",4093,"Бямба",1
5480,"ViewTranslation","Sun [abbreviated weekday]","",,"",4093,"Ня",1
5481,"ViewTranslation","Mon [abbreviated weekday]","",,"",4093,"Да",1
5482,"ViewTranslation","Tue [abbreviated weekday]","",,"",4093,"Мя",1
5483,"ViewTranslation","Wed [abbreviated weekday]","",,"",4093,"Лх",1
5484,"ViewTranslation","Thu [abbreviated weekday]","",,"",4093,"Пү",1
5485,"ViewTranslation","Fri [abbreviated weekday]","",,"",4093,"Ба",1
5486,"ViewTranslation","Sat [abbreviated weekday]","",,"",4093,"Бя",1
5487,"ViewTranslation","January [month]","",,"",4093,"Нэгдүгээр сар",1
5488,"ViewTranslation","February [month]","",,"",4093,"Хоёрдугаар сар",1
5489,"ViewTranslation","March [month]","",,"",4093,"Гуравдугаар сар",1
5490,"ViewTranslation","April [month]","",,"",4093,"Дөрөвдүгээр сар",1
5491,"ViewTranslation","May [month]","",,"",4093,"Тавдугаар сар",1
5492,"ViewTranslation","June [month]","",,"",4093,"Зургаадугар сар",1
5493,"ViewTranslation","July [month]","",,"",4093,"Долоодугаар сар",1
5494,"ViewTranslation","August [month]","",,"",4093,"Наймдугаар сар",1
5495,"ViewTranslation","September [month]","",,"",4093,"Есдүгээр сар",1
5496,"ViewTranslation","October [month]","",,"",4093,"Аравдугаар сар",1
5497,"ViewTranslation","November [month]","",,"",4093,"Арваннэгдүгээр сар",1
5498,"ViewTranslation","December [month]","",,"",4093,"Арванхоёрдгаар сар",1
5499,"ViewTranslation","Jan [abbreviated month]","",,"",4093,"1-р",1
5500,"ViewTranslation","Feb [abbreviated month]","",,"",4093,"2-р",1
5501,"ViewTranslation","Mar [abbreviated month]","",,"",4093,"3-р",1
5502,"ViewTranslation","Apr [abbreviated month]","",,"",4093,"4-р",1
5503,"ViewTranslation","May [abbreviated month]","",,"",4093,"5-р",1
5504,"ViewTranslation","Jun [abbreviated month]","",,"",4093,"6-р",1
5505,"ViewTranslation","Jul [abbreviated month]","",,"",4093,"7-р",1
5506,"ViewTranslation","Aug [abbreviated month]","",,"",4093,"8-р",1
5507,"ViewTranslation","Sep [abbreviated month]","",,"",4093,"9-р",1
5508,"ViewTranslation","Oct [abbreviated month]","",,"",4093,"10-р",1
5509,"ViewTranslation","Nov [abbreviated month]","",,"",4093,"11-р",1
5510,"ViewTranslation","Dec [abbreviated month]","",,"",4093,"12-р",1
5511,"ViewTranslation","Sunday [weekday]","",,"",3740,"रविवार",1
5512,"ViewTranslation","Monday [weekday]","",,"",3740,"सोमवार",1
5513,"ViewTranslation","Tuesday [weekday]","",,"",3740,"मंगळवार",1
5514,"ViewTranslation","Wednesday [weekday]","",,"",3740,"मंगळवार",1
5515,"ViewTranslation","Thursday [weekday]","",,"",3740,"गुरुवार",1
5516,"ViewTranslation","Friday [weekday]","",,"",3740,"शुक्रवार",1
5517,"ViewTranslation","Saturday [weekday]","",,"",3740,"शनिवार",1
5518,"ViewTranslation","Sun [abbreviated weekday]","",,"",3740,"रवि",1
5519,"ViewTranslation","Mon [abbreviated weekday]","",,"",3740,"सोम",1
5520,"ViewTranslation","Tue [abbreviated weekday]","",,"",3740,"मंगळ",1
5521,"ViewTranslation","Wed [abbreviated weekday]","",,"",3740,"बुध",1
5522,"ViewTranslation","Thu [abbreviated weekday]","",,"",3740,"गुरु",1
5523,"ViewTranslation","Fri [abbreviated weekday]","",,"",3740,"शुक्र",1
5524,"ViewTranslation","Sat [abbreviated weekday]","",,"",3740,"शनि",1
5525,"ViewTranslation","January [month]","",,"",3740,"जानेवारी",1
5526,"ViewTranslation","February [month]","",,"",3740,"फेबृवारी",1
5527,"ViewTranslation","March [month]","",,"",3740,"मार्च",1
5528,"ViewTranslation","April [month]","",,"",3740,"एप्रिल",1
5529,"ViewTranslation","May [month]","",,"",3740,"मे",1
5530,"ViewTranslation","June [month]","",,"",3740,"जून",1
5531,"ViewTranslation","July [month]","",,"",3740,"जुलै",1
5532,"ViewTranslation","August [month]","",,"",3740,"ओगस्ट",1
5533,"ViewTranslation","September [month]","",,"",3740,"सेप्टेंबर",1
5534,"ViewTranslation","October [month]","",,"",3740,"ओक्टोबर",1
5535,"ViewTranslation","November [month]","",,"",3740,"नोव्हेंबर",1
5536,"ViewTranslation","December [month]","",,"",3740,"डिसेंबर",1
5537,"ViewTranslation","Jan [abbreviated month]","",,"",3740,"जानेवारी",1
5538,"ViewTranslation","Feb [abbreviated month]","",,"",3740,"फेबृवारी",1
5539,"ViewTranslation","Mar [abbreviated month]","",,"",3740,"मार्च",1
5540,"ViewTranslation","Apr [abbreviated month]","",,"",3740,"एप्रिल",1
5541,"ViewTranslation","May [abbreviated month]","",,"",3740,"मे",1
5542,"ViewTranslation","Jun [abbreviated month]","",,"",3740,"जून",1
5543,"ViewTranslation","Jul [abbreviated month]","",,"",3740,"जुलै",1
5544,"ViewTranslation","Aug [abbreviated month]","",,"",3740,"ओगस्ट",1
5545,"ViewTranslation","Sep [abbreviated month]","",,"",3740,"सेप्टेंबर",1
5546,"ViewTranslation","Oct [abbreviated month]","",,"",3740,"ओक्टोबर",1
5547,"ViewTranslation","Nov [abbreviated month]","",,"",3740,"नोव्हेंबर",1
5548,"ViewTranslation","Dec [abbreviated month]","",,"",3740,"डिसेंबर",1
5549,"ViewTranslation","Sunday [weekday]","",,"",4184,"Ahad",1
5550,"ViewTranslation","Monday [weekday]","",,"",4184,"Isnin",1
5551,"ViewTranslation","Tuesday [weekday]","",,"",4184,"Selasa",1
5552,"ViewTranslation","Wednesday [weekday]","",,"",4184,"Rabu",1
5553,"ViewTranslation","Thursday [weekday]","",,"",4184,"Khamis",1
5554,"ViewTranslation","Friday [weekday]","",,"",4184,"Jumaat",1
5555,"ViewTranslation","Saturday [weekday]","",,"",4184,"Sabtu",1
5556,"ViewTranslation","Sun [abbreviated weekday]","",,"",4184,"Ahd",1
5557,"ViewTranslation","Mon [abbreviated weekday]","",,"",4184,"Isn",1
5558,"ViewTranslation","Tue [abbreviated weekday]","",,"",4184,"Sel",1
5559,"ViewTranslation","Wed [abbreviated weekday]","",,"",4184,"Rab",1
5560,"ViewTranslation","Thu [abbreviated weekday]","",,"",4184,"Kha",1
5561,"ViewTranslation","Fri [abbreviated weekday]","",,"",4184,"Jum",1
5562,"ViewTranslation","Sat [abbreviated weekday]","",,"",4184,"Sab",1
5563,"ViewTranslation","January [month]","",,"",4184,"Januari",1
5564,"ViewTranslation","February [month]","",,"",4184,"Februari",1
5565,"ViewTranslation","March [month]","",,"",4184,"Mac",1
5566,"ViewTranslation","April [month]","",,"",4184,"April",1
5567,"ViewTranslation","May [month]","",,"",4184,"Mei",1
5568,"ViewTranslation","June [month]","",,"",4184,"Jun",1
5569,"ViewTranslation","July [month]","",,"",4184,"Julai",1
5570,"ViewTranslation","August [month]","",,"",4184,"Ogos",1
5571,"ViewTranslation","September [month]","",,"",4184,"September",1
5572,"ViewTranslation","October [month]","",,"",4184,"Oktober",1
5573,"ViewTranslation","November [month]","",,"",4184,"November",1
5574,"ViewTranslation","December [month]","",,"",4184,"Disember",1
5575,"ViewTranslation","Jan [abbreviated month]","",,"",4184,"Jan",1
5576,"ViewTranslation","Feb [abbreviated month]","",,"",4184,"Feb",1
5577,"ViewTranslation","Mar [abbreviated month]","",,"",4184,"Mac",1
5578,"ViewTranslation","Apr [abbreviated month]","",,"",4184,"Apr",1
5579,"ViewTranslation","May [abbreviated month]","",,"",4184,"Mei",1
5580,"ViewTranslation","Jun [abbreviated month]","",,"",4184,"Jun",1
5581,"ViewTranslation","Jul [abbreviated month]","",,"",4184,"Jul",1
5582,"ViewTranslation","Aug [abbreviated month]","",,"",4184,"Ogos",1
5583,"ViewTranslation","Sep [abbreviated month]","",,"",4184,"Sep",1
5584,"ViewTranslation","Oct [abbreviated month]","",,"",4184,"Okt",1
5585,"ViewTranslation","Nov [abbreviated month]","",,"",4184,"Nov",1
5586,"ViewTranslation","Dec [abbreviated month]","",,"",4184,"Dis",1
5587,"ViewTranslation","Sunday [weekday]","",,"",4022,"Il-ħadd",1
5588,"ViewTranslation","Monday [weekday]","",,"",4022,"It-tnejn",1
5589,"ViewTranslation","Tuesday [weekday]","",,"",4022,"It-tlieta",1
5590,"ViewTranslation","Wednesday [weekday]","",,"",4022,"L-erbgħa",1
5591,"ViewTranslation","Thursday [weekday]","",,"",4022,"Il-ħamis",1
5592,"ViewTranslation","Friday [weekday]","",,"",4022,"Il-ġimgħa",1
5593,"ViewTranslation","Saturday [weekday]","",,"",4022,"Is-sibt",1
5594,"ViewTranslation","Sun [abbreviated weekday]","",,"",4022,"Ħad",1
5595,"ViewTranslation","Mon [abbreviated weekday]","",,"",4022,"Tne",1
5596,"ViewTranslation","Tue [abbreviated weekday]","",,"",4022,"Tli",1
5597,"ViewTranslation","Wed [abbreviated weekday]","",,"",4022,"Erb",1
5598,"ViewTranslation","Thu [abbreviated weekday]","",,"",4022,"Ħam",1
5599,"ViewTranslation","Fri [abbreviated weekday]","",,"",4022,"Ġim",1
5600,"ViewTranslation","Sat [abbreviated weekday]","",,"",4022,"Sib",1
5601,"ViewTranslation","January [month]","",,"",4022,"Jannar",1
5602,"ViewTranslation","February [month]","",,"",4022,"Frar",1
5603,"ViewTranslation","March [month]","",,"",4022,"Marzu",1
5604,"ViewTranslation","April [month]","",,"",4022,"April",1
5605,"ViewTranslation","May [month]","",,"",4022,"Mejju",1
5606,"ViewTranslation","June [month]","",,"",4022,"Ġunju",1
5607,"ViewTranslation","July [month]","",,"",4022,"Lulju",1
5608,"ViewTranslation","August [month]","",,"",4022,"Awissu",1
5609,"ViewTranslation","September [month]","",,"",4022,"Settembru",1
5610,"ViewTranslation","October [month]","",,"",4022,"Ottubru",1
5611,"ViewTranslation","November [month]","",,"",4022,"Novembru",1
5612,"ViewTranslation","December [month]","",,"",4022,"Diċembru ",1
5613,"ViewTranslation","Jan [abbreviated month]","",,"",4022,"Jan",1
5614,"ViewTranslation","Feb [abbreviated month]","",,"",4022,"Fra",1
5615,"ViewTranslation","Mar [abbreviated month]","",,"",4022,"Mar",1
5616,"ViewTranslation","Apr [abbreviated month]","",,"",4022,"Apr",1
5617,"ViewTranslation","May [abbreviated month]","",,"",4022,"Mej",1
5618,"ViewTranslation","Jun [abbreviated month]","",,"",4022,"Ġun",1
5619,"ViewTranslation","Jul [abbreviated month]","",,"",4022,"Lul",1
5620,"ViewTranslation","Aug [abbreviated month]","",,"",4022,"Awi",1
5621,"ViewTranslation","Sep [abbreviated month]","",,"",4022,"Set",1
5622,"ViewTranslation","Oct [abbreviated month]","",,"",4022,"Ott",1
5623,"ViewTranslation","Nov [abbreviated month]","",,"",4022,"Nov",1
5624,"ViewTranslation","Dec [abbreviated month]","",,"",4022,"Diċ",1
5625,"ViewTranslation","Sunday [weekday]","",,"",4695,"Søndag",1
5626,"ViewTranslation","Monday [weekday]","",,"",4695,"Mandag",1
5627,"ViewTranslation","Tuesday [weekday]","",,"",4695,"Tirsdag",1
5628,"ViewTranslation","Wednesday [weekday]","",,"",4695,"Onsdag",1
5629,"ViewTranslation","Thursday [weekday]","",,"",4695,"Torsdag",1
5630,"ViewTranslation","Friday [weekday]","",,"",4695,"Fredag",1
5631,"ViewTranslation","Saturday [weekday]","",,"",4695,"Lørdag",1
5632,"ViewTranslation","Sun [abbreviated weekday]","",,"",4695,"Søn",1
5633,"ViewTranslation","Mon [abbreviated weekday]","",,"",4695,"Man",1
5634,"ViewTranslation","Tue [abbreviated weekday]","",,"",4695,"Tir",1
5635,"ViewTranslation","Wed [abbreviated weekday]","",,"",4695,"Ons",1
5636,"ViewTranslation","Thu [abbreviated weekday]","",,"",4695,"Tor",1
5637,"ViewTranslation","Fri [abbreviated weekday]","",,"",4695,"Fre",1
5638,"ViewTranslation","Sat [abbreviated weekday]","",,"",4695,"Lør",1
5639,"ViewTranslation","January [month]","",,"",4695,"Januar",1
5640,"ViewTranslation","February [month]","",,"",4695,"Februar",1
5641,"ViewTranslation","March [month]","",,"",4695,"Mars",1
5642,"ViewTranslation","April [month]","",,"",4695,"April",1
5643,"ViewTranslation","May [month]","",,"",4695,"Mai",1
5644,"ViewTranslation","June [month]","",,"",4695,"Juni",1
5645,"ViewTranslation","July [month]","",,"",4695,"Juli",1
5646,"ViewTranslation","August [month]","",,"",4695,"August",1
5647,"ViewTranslation","September [month]","",,"",4695,"September",1
5648,"ViewTranslation","October [month]","",,"",4695,"Oktober",1
5649,"ViewTranslation","November [month]","",,"",4695,"November",1
5650,"ViewTranslation","December [month]","",,"",4695,"Desember",1
5651,"ViewTranslation","Jan [abbreviated month]","",,"",4695,"Jan",1
5652,"ViewTranslation","Feb [abbreviated month]","",,"",4695,"Feb",1
5653,"ViewTranslation","Mar [abbreviated month]","",,"",4695,"Mar",1
5654,"ViewTranslation","Apr [abbreviated month]","",,"",4695,"Apr",1
5655,"ViewTranslation","May [abbreviated month]","",,"",4695,"Mai",1
5656,"ViewTranslation","Jun [abbreviated month]","",,"",4695,"Jun",1
5657,"ViewTranslation","Jul [abbreviated month]","",,"",4695,"Jul",1
5658,"ViewTranslation","Aug [abbreviated month]","",,"",4695,"Aug",1
5659,"ViewTranslation","Sep [abbreviated month]","",,"",4695,"Sep",1
5660,"ViewTranslation","Oct [abbreviated month]","",,"",4695,"Okt",1
5661,"ViewTranslation","Nov [abbreviated month]","",,"",4695,"Nov",1
5662,"ViewTranslation","Dec [abbreviated month]","",,"",4695,"Des",1
5663,"ViewTranslation","Sunday [weekday]","",,"",4499,"आइतबार ",1
5664,"ViewTranslation","Monday [weekday]","",,"",4499,"सोमबार ",1
5665,"ViewTranslation","Tuesday [weekday]","",,"",4499,"मंगलबार ",1
5666,"ViewTranslation","Wednesday [weekday]","",,"",4499,"बुधबार ",1
5667,"ViewTranslation","Thursday [weekday]","",,"",4499,"बिहिबार ",1
5668,"ViewTranslation","Friday [weekday]","",,"",4499,"शुक्रबार ",1
5669,"ViewTranslation","Saturday [weekday]","",,"",4499,"शनिबार ",1
5670,"ViewTranslation","Sun [abbreviated weekday]","",,"",4499,"आइत ",1
5671,"ViewTranslation","Mon [abbreviated weekday]","",,"",4499,"सोम ",1
5672,"ViewTranslation","Tue [abbreviated weekday]","",,"",4499,"मंगल ",1
5673,"ViewTranslation","Wed [abbreviated weekday]","",,"",4499,"बुध ",1
5674,"ViewTranslation","Thu [abbreviated weekday]","",,"",4499,"बिहि ",1
5675,"ViewTranslation","Fri [abbreviated weekday]","",,"",4499,"शुक्र ",1
5676,"ViewTranslation","Sat [abbreviated weekday]","",,"",4499,"शनि ",1
5677,"ViewTranslation","January [month]","",,"",4499,"जनवरी",1
5678,"ViewTranslation","February [month]","",,"",4499,"फ़रवरी",1
5679,"ViewTranslation","March [month]","",,"",4499,"मार्च",1
5680,"ViewTranslation","April [month]","",,"",4499,"अप्रेल",1
5681,"ViewTranslation","May [month]","",,"",4499,"मई",1
5682,"ViewTranslation","June [month]","",,"",4499,"जून",1
5683,"ViewTranslation","July [month]","",,"",4499,"जुलाई",1
5684,"ViewTranslation","August [month]","",,"",4499,"अगस्त",1
5685,"ViewTranslation","September [month]","",,"",4499,"सितम्बर",1
5686,"ViewTranslation","October [month]","",,"",4499,"अक्टूबर",1
5687,"ViewTranslation","November [month]","",,"",4499,"नवम्बर",1
5688,"ViewTranslation","December [month]","",,"",4499,"दिसम्बर",1
5689,"ViewTranslation","Jan [abbreviated month]","",,"",4499,"जनवरी",1
5690,"ViewTranslation","Feb [abbreviated month]","",,"",4499,"फ़रवरी",1
5691,"ViewTranslation","Mar [abbreviated month]","",,"",4499,"मार्च",1
5692,"ViewTranslation","Apr [abbreviated month]","",,"",4499,"अप्रेल",1
5693,"ViewTranslation","May [abbreviated month]","",,"",4499,"मई",1
5694,"ViewTranslation","Jun [abbreviated month]","",,"",4499,"जून",1
5695,"ViewTranslation","Jul [abbreviated month]","",,"",4499,"जुलाई",1
5696,"ViewTranslation","Aug [abbreviated month]","",,"",4499,"अगस्त",1
5697,"ViewTranslation","Sep [abbreviated month]","",,"",4499,"सितम्बर",1
5698,"ViewTranslation","Oct [abbreviated month]","",,"",4499,"अक्टूबर",1
5699,"ViewTranslation","Nov [abbreviated month]","",,"",4499,"नवम्बर",1
5700,"ViewTranslation","Dec [abbreviated month]","",,"",4499,"दिसम्बर",1
5701,"ViewTranslation","Sunday [weekday]","",,"",4628,"zondag",1
5702,"ViewTranslation","Monday [weekday]","",,"",4628,"maandag",1
5703,"ViewTranslation","Tuesday [weekday]","",,"",4628,"dinsdag",1
5704,"ViewTranslation","Wednesday [weekday]","",,"",4628,"woensdag",1
5705,"ViewTranslation","Thursday [weekday]","",,"",4628,"donderdag",1
5706,"ViewTranslation","Friday [weekday]","",,"",4628,"vrijdag",1
5707,"ViewTranslation","Saturday [weekday]","",,"",4628,"zaterdag",1
5708,"ViewTranslation","Sun [abbreviated weekday]","",,"",4628,"zo",1
5709,"ViewTranslation","Mon [abbreviated weekday]","",,"",4628,"ma",1
5710,"ViewTranslation","Tue [abbreviated weekday]","",,"",4628,"di",1
5711,"ViewTranslation","Wed [abbreviated weekday]","",,"",4628,"wo",1
5712,"ViewTranslation","Thu [abbreviated weekday]","",,"",4628,"do",1
5713,"ViewTranslation","Fri [abbreviated weekday]","",,"",4628,"vr",1
5714,"ViewTranslation","Sat [abbreviated weekday]","",,"",4628,"za",1
5715,"ViewTranslation","January [month]","",,"",4628,"januari",1
5716,"ViewTranslation","February [month]","",,"",4628,"februari",1
5717,"ViewTranslation","March [month]","",,"",4628,"maart",1
5718,"ViewTranslation","April [month]","",,"",4628,"april",1
5719,"ViewTranslation","May [month]","",,"",4628,"mei",1
5720,"ViewTranslation","June [month]","",,"",4628,"juni",1
5721,"ViewTranslation","July [month]","",,"",4628,"juli",1
5722,"ViewTranslation","August [month]","",,"",4628,"augustus",1
5723,"ViewTranslation","September [month]","",,"",4628,"september",1
5724,"ViewTranslation","October [month]","",,"",4628,"oktober",1
5725,"ViewTranslation","November [month]","",,"",4628,"november",1
5726,"ViewTranslation","December [month]","",,"",4628,"december",1
5727,"ViewTranslation","Jan [abbreviated month]","",,"",4628,"jan",1
5728,"ViewTranslation","Feb [abbreviated month]","",,"",4628,"feb",1
5729,"ViewTranslation","Mar [abbreviated month]","",,"",4628,"mrt",1
5730,"ViewTranslation","Apr [abbreviated month]","",,"",4628,"apr",1
5731,"ViewTranslation","May [abbreviated month]","",,"",4628,"mei",1
5732,"ViewTranslation","Jun [abbreviated month]","",,"",4628,"jun",1
5733,"ViewTranslation","Jul [abbreviated month]","",,"",4628,"jul",1
5734,"ViewTranslation","Aug [abbreviated month]","",,"",4628,"aug",1
5735,"ViewTranslation","Sep [abbreviated month]","",,"",4628,"sep",1
5736,"ViewTranslation","Oct [abbreviated month]","",,"",4628,"okt",1
5737,"ViewTranslation","Nov [abbreviated month]","",,"",4628,"nov",1
5738,"ViewTranslation","Dec [abbreviated month]","",,"",4628,"dec",1
5739,"ViewTranslation","Sunday [weekday]","",,"",4682,"Sundag ",1
5740,"ViewTranslation","Monday [weekday]","",,"",4682,"Måndag ",1
5741,"ViewTranslation","Tuesday [weekday]","",,"",4682,"Tysdag ",1
5742,"ViewTranslation","Wednesday [weekday]","",,"",4682,"Onsdag ",1
5743,"ViewTranslation","Thursday [weekday]","",,"",4682,"Torsdag ",1
5744,"ViewTranslation","Friday [weekday]","",,"",4682,"Fredag ",1
5745,"ViewTranslation","Saturday [weekday]","",,"",4682,"Laurdag ",1
5746,"ViewTranslation","Sun [abbreviated weekday]","",,"",4682,"Su ",1
5747,"ViewTranslation","Mon [abbreviated weekday]","",,"",4682,"Må ",1
5748,"ViewTranslation","Tue [abbreviated weekday]","",,"",4682,"Ty ",1
5749,"ViewTranslation","Wed [abbreviated weekday]","",,"",4682,"On ",1
5750,"ViewTranslation","Thu [abbreviated weekday]","",,"",4682,"To ",1
5751,"ViewTranslation","Fri [abbreviated weekday]","",,"",4682,"Fr ",1
5752,"ViewTranslation","Sat [abbreviated weekday]","",,"",4682,"Lau ",1
5753,"ViewTranslation","January [month]","",,"",4682,"Januar",1
5754,"ViewTranslation","February [month]","",,"",4682,"Februar",1
5755,"ViewTranslation","March [month]","",,"",4682,"Mars",1
5756,"ViewTranslation","April [month]","",,"",4682,"April",1
5757,"ViewTranslation","May [month]","",,"",4682,"Mai",1
5758,"ViewTranslation","June [month]","",,"",4682,"Juni",1
5759,"ViewTranslation","July [month]","",,"",4682,"Juli",1
5760,"ViewTranslation","August [month]","",,"",4682,"August",1
5761,"ViewTranslation","September [month]","",,"",4682,"September",1
5762,"ViewTranslation","October [month]","",,"",4682,"Oktober",1
5763,"ViewTranslation","November [month]","",,"",4682,"November",1
5764,"ViewTranslation","December [month]","",,"",4682,"Desember",1
5765,"ViewTranslation","Jan [abbreviated month]","",,"",4682,"Jan",1
5766,"ViewTranslation","Feb [abbreviated month]","",,"",4682,"Feb",1
5767,"ViewTranslation","Mar [abbreviated month]","",,"",4682,"Mar",1
5768,"ViewTranslation","Apr [abbreviated month]","",,"",4682,"Apr",1
5769,"ViewTranslation","May [abbreviated month]","",,"",4682,"Mai",1
5770,"ViewTranslation","Jun [abbreviated month]","",,"",4682,"Jun",1
5771,"ViewTranslation","Jul [abbreviated month]","",,"",4682,"Jul",1
5772,"ViewTranslation","Aug [abbreviated month]","",,"",4682,"Aug",1
5773,"ViewTranslation","Sep [abbreviated month]","",,"",4682,"Sep",1
5774,"ViewTranslation","Oct [abbreviated month]","",,"",4682,"Okt",1
5775,"ViewTranslation","Nov [abbreviated month]","",,"",4682,"Nov",1
5776,"ViewTranslation","Dec [abbreviated month]","",,"",4682,"Des",1
5777,"ViewTranslation","Sunday [weekday]","",,"",4709,"Søndag",1
5778,"ViewTranslation","Monday [weekday]","",,"",4709,"Mandag",1
5779,"ViewTranslation","Tuesday [weekday]","",,"",4709,"Tirsdag",1
5780,"ViewTranslation","Wednesday [weekday]","",,"",4709,"Onsdag",1
5781,"ViewTranslation","Thursday [weekday]","",,"",4709,"Torsdag",1
5782,"ViewTranslation","Friday [weekday]","",,"",4709,"Fredag",1
5783,"ViewTranslation","Saturday [weekday]","",,"",4709,"Lørdag",1
5784,"ViewTranslation","Sun [abbreviated weekday]","",,"",4709,"Søn",1
5785,"ViewTranslation","Mon [abbreviated weekday]","",,"",4709,"Man",1
5786,"ViewTranslation","Tue [abbreviated weekday]","",,"",4709,"Tir",1
5787,"ViewTranslation","Wed [abbreviated weekday]","",,"",4709,"Ons",1
5788,"ViewTranslation","Thu [abbreviated weekday]","",,"",4709,"Tor",1
5789,"ViewTranslation","Fri [abbreviated weekday]","",,"",4709,"Fre",1
5790,"ViewTranslation","Sat [abbreviated weekday]","",,"",4709,"Lør",1
5791,"ViewTranslation","January [month]","",,"",4709,"Januar",1
5792,"ViewTranslation","February [month]","",,"",4709,"Februar",1
5793,"ViewTranslation","March [month]","",,"",4709,"Mars",1
5794,"ViewTranslation","April [month]","",,"",4709,"April",1
5795,"ViewTranslation","May [month]","",,"",4709,"Mai",1
5796,"ViewTranslation","June [month]","",,"",4709,"Juni",1
5797,"ViewTranslation","July [month]","",,"",4709,"Juli",1
5798,"ViewTranslation","August [month]","",,"",4709,"August",1
5799,"ViewTranslation","September [month]","",,"",4709,"September",1
5800,"ViewTranslation","October [month]","",,"",4709,"Oktober",1
5801,"ViewTranslation","November [month]","",,"",4709,"November",1
5802,"ViewTranslation","December [month]","",,"",4709,"Desember",1
5803,"ViewTranslation","Jan [abbreviated month]","",,"",4709,"Jan",1
5804,"ViewTranslation","Feb [abbreviated month]","",,"",4709,"Feb",1
5805,"ViewTranslation","Mar [abbreviated month]","",,"",4709,"Mar",1
5806,"ViewTranslation","Apr [abbreviated month]","",,"",4709,"Apr",1
5807,"ViewTranslation","May [abbreviated month]","",,"",4709,"Mai",1
5808,"ViewTranslation","Jun [abbreviated month]","",,"",4709,"Jun",1
5809,"ViewTranslation","Jul [abbreviated month]","",,"",4709,"Jul",1
5810,"ViewTranslation","Aug [abbreviated month]","",,"",4709,"Aug",1
5811,"ViewTranslation","Sep [abbreviated month]","",,"",4709,"Sep",1
5812,"ViewTranslation","Oct [abbreviated month]","",,"",4709,"Okt",1
5813,"ViewTranslation","Nov [abbreviated month]","",,"",4709,"Nov",1
5814,"ViewTranslation","Dec [abbreviated month]","",,"",4709,"Des",1
5815,"ViewTranslation","Sunday [weekday]","",,"",4867,"Dimenge",1
5816,"ViewTranslation","Monday [weekday]","",,"",4867,"Diluns",1
5817,"ViewTranslation","Tuesday [weekday]","",,"",4867,"Dimars",1
5818,"ViewTranslation","Wednesday [weekday]","",,"",4867,"Dimecres",1
5819,"ViewTranslation","Thursday [weekday]","",,"",4867,"Dijóus",1
5820,"ViewTranslation","Friday [weekday]","",,"",4867,"Divendres",1
5821,"ViewTranslation","Saturday [weekday]","",,"",4867,"Disabte",1
5822,"ViewTranslation","Sun [abbreviated weekday]","",,"",4867,"Dim",1
5823,"ViewTranslation","Mon [abbreviated weekday]","",,"",4867,"Lun",1
5824,"ViewTranslation","Tue [abbreviated weekday]","",,"",4867,"Mar",1
5825,"ViewTranslation","Wed [abbreviated weekday]","",,"",4867,"Mec",1
5826,"ViewTranslation","Thu [abbreviated weekday]","",,"",4867,"Jóu",1
5827,"ViewTranslation","Fri [abbreviated weekday]","",,"",4867,"Ven",1
5828,"ViewTranslation","Sat [abbreviated weekday]","",,"",4867,"Sab",1
5829,"ViewTranslation","January [month]","",,"",4867,"Genièr",1
5830,"ViewTranslation","February [month]","",,"",4867,"Febrièr",1
5831,"ViewTranslation","March [month]","",,"",4867,"Març",1
5832,"ViewTranslation","April [month]","",,"",4867,"Abrial",1
5833,"ViewTranslation","May [month]","",,"",4867,"Mai",1
5834,"ViewTranslation","June [month]","",,"",4867,"Junh",1
5835,"ViewTranslation","July [month]","",,"",4867,"Julhet",1
5836,"ViewTranslation","August [month]","",,"",4867,"Agóst",1
5837,"ViewTranslation","September [month]","",,"",4867,"Setembre",1
5838,"ViewTranslation","October [month]","",,"",4867,"Octobre",1
5839,"ViewTranslation","November [month]","",,"",4867,"Novembre",1
5840,"ViewTranslation","December [month]","",,"",4867,"Decembre",1
5841,"ViewTranslation","Jan [abbreviated month]","",,"",4867,"Gen",1
5842,"ViewTranslation","Feb [abbreviated month]","",,"",4867,"Feb",1
5843,"ViewTranslation","Mar [abbreviated month]","",,"",4867,"Mar",1
5844,"ViewTranslation","Apr [abbreviated month]","",,"",4867,"Abr",1
5845,"ViewTranslation","May [abbreviated month]","",,"",4867,"Mai",1
5846,"ViewTranslation","Jun [abbreviated month]","",,"",4867,"Jun",1
5847,"ViewTranslation","Jul [abbreviated month]","",,"",4867,"Jul",1
5848,"ViewTranslation","Aug [abbreviated month]","",,"",4867,"Agó",1
5849,"ViewTranslation","Sep [abbreviated month]","",,"",4867,"Set",1
5850,"ViewTranslation","Oct [abbreviated month]","",,"",4867,"Oct",1
5851,"ViewTranslation","Nov [abbreviated month]","",,"",4867,"Nov",1
5852,"ViewTranslation","Dec [abbreviated month]","",,"",4867,"Dec",1
5853,"ViewTranslation","Sunday [weekday]","",,"",4967,"Dilbata",1
5854,"ViewTranslation","Monday [weekday]","",,"",4967,"Wiixata",1
5855,"ViewTranslation","Tuesday [weekday]","",,"",4967,"Qibxata",1
5856,"ViewTranslation","Wednesday [weekday]","",,"",4967,"Roobii",1
5857,"ViewTranslation","Thursday [weekday]","",,"",4967,"Kamiisa",1
5858,"ViewTranslation","Friday [weekday]","",,"",4967,"Jimaata",1
5859,"ViewTranslation","Saturday [weekday]","",,"",4967,"Sanbata",1
5860,"ViewTranslation","Sun [abbreviated weekday]","",,"",4967,"Dil",1
5861,"ViewTranslation","Mon [abbreviated weekday]","",,"",4967,"Wix",1
5862,"ViewTranslation","Tue [abbreviated weekday]","",,"",4967,"Qib",1
5863,"ViewTranslation","Wed [abbreviated weekday]","",,"",4967,"Rob",1
5864,"ViewTranslation","Thu [abbreviated weekday]","",,"",4967,"Kam",1
5865,"ViewTranslation","Fri [abbreviated weekday]","",,"",4967,"Jim",1
5866,"ViewTranslation","Sat [abbreviated weekday]","",,"",4967,"San",1
5867,"ViewTranslation","January [month]","",,"",4967,"Amajjii",1
5868,"ViewTranslation","February [month]","",,"",4967,"Guraandhala",1
5869,"ViewTranslation","March [month]","",,"",4967,"Bitooteessa",1
5870,"ViewTranslation","April [month]","",,"",4967,"Elba",1
5871,"ViewTranslation","May [month]","",,"",4967,"Caamsa",1
5872,"ViewTranslation","June [month]","",,"",4967,"Waxabajjii",1
5873,"ViewTranslation","July [month]","",,"",4967,"Adooleessa",1
5874,"ViewTranslation","August [month]","",,"",4967,"Hagayya",1
5875,"ViewTranslation","September [month]","",,"",4967,"Fuulbana",1
5876,"ViewTranslation","October [month]","",,"",4967,"Onkololeessa",1
5877,"ViewTranslation","November [month]","",,"",4967,"Sadaasa",1
5878,"ViewTranslation","December [month]","",,"",4967,"Muddee",1
5879,"ViewTranslation","Jan [abbreviated month]","",,"",4967,"Ama",1
5880,"ViewTranslation","Feb [abbreviated month]","",,"",4967,"Gur",1
5881,"ViewTranslation","Mar [abbreviated month]","",,"",4967,"Bit",1
5882,"ViewTranslation","Apr [abbreviated month]","",,"",4967,"Elb",1
5883,"ViewTranslation","May [abbreviated month]","",,"",4967,"Cam",1
5884,"ViewTranslation","Jun [abbreviated month]","",,"",4967,"Wax",1
5885,"ViewTranslation","Jul [abbreviated month]","",,"",4967,"Ado",1
5886,"ViewTranslation","Aug [abbreviated month]","",,"",4967,"Hag",1
5887,"ViewTranslation","Sep [abbreviated month]","",,"",4967,"Ful",1
5888,"ViewTranslation","Oct [abbreviated month]","",,"",4967,"Onk",1
5889,"ViewTranslation","Nov [abbreviated month]","",,"",4967,"Sad",1
5890,"ViewTranslation","Dec [abbreviated month]","",,"",4967,"Mud",1
5891,"ViewTranslation","Sunday [weekday]","",,"",5031,"ਆੈਤਵਾਰ ",1
5892,"ViewTranslation","Monday [weekday]","",,"",5031,"ਸੋਮਵਾਰ ",1
5893,"ViewTranslation","Tuesday [weekday]","",,"",5031,"ਮੰਗਲਵਾਰ ",1
5894,"ViewTranslation","Wednesday [weekday]","",,"",5031,"ਬੁੱਧਵਾਰ ",1
5895,"ViewTranslation","Thursday [weekday]","",,"",5031,"ਵੀਰਵਾਰ ",1
5896,"ViewTranslation","Friday [weekday]","",,"",5031,"ਸ਼ੁਕਰਵਾਰ ",1
5897,"ViewTranslation","Saturday [weekday]","",,"",5031,"ਸ਼ਨੀਵਾਰ ",1
5898,"ViewTranslation","Sun [abbreviated weekday]","",,"",5031,"ਆੈਤ ",1
5899,"ViewTranslation","Mon [abbreviated weekday]","",,"",5031,"ਸੋਮ ",1
5900,"ViewTranslation","Tue [abbreviated weekday]","",,"",5031,"ਮੰਗਲ ",1
5901,"ViewTranslation","Wed [abbreviated weekday]","",,"",5031,"ਬੁੱਧ ",1
5902,"ViewTranslation","Thu [abbreviated weekday]","",,"",5031,"ਵੀਰ ",1
5903,"ViewTranslation","Fri [abbreviated weekday]","",,"",5031,"ਸ਼ੁਕਰ ",1
5904,"ViewTranslation","Sat [abbreviated weekday]","",,"",5031,"ਸ਼ਨੀ ",1
5905,"ViewTranslation","January [month]","",,"",5031,"ਜਨਵਰੀ",1
5906,"ViewTranslation","February [month]","",,"",5031,"ਫ਼ਰਵਰੀ",1
5907,"ViewTranslation","March [month]","",,"",5031,"ਮਾਰਛ",1
5908,"ViewTranslation","April [month]","",,"",5031,"ਅਪ਼ੈਲ",1
5909,"ViewTranslation","May [month]","",,"",5031,"ਮੲੀ",1
5910,"ViewTranslation","June [month]","",,"",5031,"ਜੂਨ",1
5911,"ViewTranslation","July [month]","",,"",5031,"ਜੁਲਾੲੀ",1
5912,"ViewTranslation","August [month]","",,"",5031,"ਅਗਸਤ",1
5913,"ViewTranslation","September [month]","",,"",5031,"ਸਿਤੰਬਰ",1
5914,"ViewTranslation","October [month]","",,"",5031,"ਅਕਤੂਬਰ",1
5915,"ViewTranslation","November [month]","",,"",5031,"ਨਵੰਬਰ",1
5916,"ViewTranslation","December [month]","",,"",5031,"ਦਿਸੰਬਰ",1
5917,"ViewTranslation","Jan [abbreviated month]","",,"",5031,"ਜਨਵਰੀ",1
5918,"ViewTranslation","Feb [abbreviated month]","",,"",5031,"ਫ਼ਰਵਰੀ",1
5919,"ViewTranslation","Mar [abbreviated month]","",,"",5031,"ਮਾਰਛ",1
5920,"ViewTranslation","Apr [abbreviated month]","",,"",5031,"ਅਪ਼ੈਲ",1
5921,"ViewTranslation","May [abbreviated month]","",,"",5031,"ਮੲੀ",1
5922,"ViewTranslation","Jun [abbreviated month]","",,"",5031,"ਜੂਨ",1
5923,"ViewTranslation","Jul [abbreviated month]","",,"",5031,"ਜੁਲਾੲੀ",1
5924,"ViewTranslation","Aug [abbreviated month]","",,"",5031,"ਅਗਸਤ",1
5925,"ViewTranslation","Sep [abbreviated month]","",,"",5031,"ਸਿਤੰਬਰ",1
5926,"ViewTranslation","Oct [abbreviated month]","",,"",5031,"ਅਕਤੂਬਰ",1
5927,"ViewTranslation","Nov [abbreviated month]","",,"",5031,"ਨਵੰਬਰ",1
5928,"ViewTranslation","Dec [abbreviated month]","",,"",5031,"ਦਿਸੰਬਰ",1
5929,"ViewTranslation","Sunday [weekday]","",,"",5244,"Niedziela",1
5930,"ViewTranslation","Monday [weekday]","",,"",5244,"Poniedziałek",1
5931,"ViewTranslation","Tuesday [weekday]","",,"",5244,"Wtorek",1
5932,"ViewTranslation","Wednesday [weekday]","",,"",5244,"Środa",1
5933,"ViewTranslation","Thursday [weekday]","",,"",5244,"Czwartek",1
5934,"ViewTranslation","Friday [weekday]","",,"",5244,"Piątek",1
5935,"ViewTranslation","Saturday [weekday]","",,"",5244,"Sobota",1
5936,"ViewTranslation","Sun [abbreviated weekday]","",,"",5244,"Nie",1
5937,"ViewTranslation","Mon [abbreviated weekday]","",,"",5244,"Pon",1
5938,"ViewTranslation","Tue [abbreviated weekday]","",,"",5244,"Wto",1
5939,"ViewTranslation","Wed [abbreviated weekday]","",,"",5244,"Śro",1
5940,"ViewTranslation","Thu [abbreviated weekday]","",,"",5244,"Czw",1
5941,"ViewTranslation","Fri [abbreviated weekday]","",,"",5244,"Pią",1
5942,"ViewTranslation","Sat [abbreviated weekday]","",,"",5244,"Sob",1
5943,"ViewTranslation","January [month]","",,"",5244,"Styczeń",1
5944,"ViewTranslation","February [month]","",,"",5244,"Luty",1
5945,"ViewTranslation","March [month]","",,"",5244,"Marzec",1
5946,"ViewTranslation","April [month]","",,"",5244,"Kwiecień",1
5947,"ViewTranslation","May [month]","",,"",5244,"Maj",1
5948,"ViewTranslation","June [month]","",,"",5244,"Czerwiec",1
5949,"ViewTranslation","July [month]","",,"",5244,"Lipiec",1
5950,"ViewTranslation","August [month]","",,"",5244,"Sierpień",1
5951,"ViewTranslation","September [month]","",,"",5244,"Wrzesień",1
5952,"ViewTranslation","October [month]","",,"",5244,"Październik",1
5953,"ViewTranslation","November [month]","",,"",5244,"Listopad",1
5954,"ViewTranslation","December [month]","",,"",5244,"Grudzień",1
5955,"ViewTranslation","Jan [abbreviated month]","",,"",5244,"Sty",1
5956,"ViewTranslation","Feb [abbreviated month]","",,"",5244,"Lut",1
5957,"ViewTranslation","Mar [abbreviated month]","",,"",5244,"Mar",1
5958,"ViewTranslation","Apr [abbreviated month]","",,"",5244,"Kwi",1
5959,"ViewTranslation","May [abbreviated month]","",,"",5244,"Maj",1
5960,"ViewTranslation","Jun [abbreviated month]","",,"",5244,"Cze",1
5961,"ViewTranslation","Jul [abbreviated month]","",,"",5244,"Lip",1
5962,"ViewTranslation","Aug [abbreviated month]","",,"",5244,"Sie",1
5963,"ViewTranslation","Sep [abbreviated month]","",,"",5244,"Wrz",1
5964,"ViewTranslation","Oct [abbreviated month]","",,"",5244,"Paź",1
5965,"ViewTranslation","Nov [abbreviated month]","",,"",5244,"Lis",1
5966,"ViewTranslation","Dec [abbreviated month]","",,"",5244,"Gru",1
5967,"ViewTranslation","Sunday [weekday]","",,"",5250,"Domingo",1
5968,"ViewTranslation","Monday [weekday]","",,"",5250,"Segunda",1
5969,"ViewTranslation","Tuesday [weekday]","",,"",5250,"Terça",1
5970,"ViewTranslation","Wednesday [weekday]","",,"",5250,"Quarta",1
5971,"ViewTranslation","Thursday [weekday]","",,"",5250,"Quinta",1
5972,"ViewTranslation","Friday [weekday]","",,"",5250,"Sexta",1
5973,"ViewTranslation","Saturday [weekday]","",,"",5250,"Sábado",1
5974,"ViewTranslation","Sun [abbreviated weekday]","",,"",5250,"Dom",1
5975,"ViewTranslation","Mon [abbreviated weekday]","",,"",5250,"Seg",1
5976,"ViewTranslation","Tue [abbreviated weekday]","",,"",5250,"Ter",1
5977,"ViewTranslation","Wed [abbreviated weekday]","",,"",5250,"Qua",1
5978,"ViewTranslation","Thu [abbreviated weekday]","",,"",5250,"Qui",1
5979,"ViewTranslation","Fri [abbreviated weekday]","",,"",5250,"Sex",1
5980,"ViewTranslation","Sat [abbreviated weekday]","",,"",5250,"Sáb",1
5981,"ViewTranslation","January [month]","",,"",5250,"Janeiro",1
5982,"ViewTranslation","February [month]","",,"",5250,"Fevereiro",1
5983,"ViewTranslation","March [month]","",,"",5250,"Março",1
5984,"ViewTranslation","April [month]","",,"",5250,"Abril",1
5985,"ViewTranslation","May [month]","",,"",5250,"Maio",1
5986,"ViewTranslation","June [month]","",,"",5250,"Junho",1
5987,"ViewTranslation","July [month]","",,"",5250,"Julho",1
5988,"ViewTranslation","August [month]","",,"",5250,"Agosto",1
5989,"ViewTranslation","September [month]","",,"",5250,"Setembro",1
5990,"ViewTranslation","October [month]","",,"",5250,"Outubro",1
5991,"ViewTranslation","November [month]","",,"",5250,"Novembro",1
5992,"ViewTranslation","December [month]","",,"",5250,"Dezembro",1
5993,"ViewTranslation","Jan [abbreviated month]","",,"",5250,"Jan",1
5994,"ViewTranslation","Feb [abbreviated month]","",,"",5250,"Fev",1
5995,"ViewTranslation","Mar [abbreviated month]","",,"",5250,"Mar",1
5996,"ViewTranslation","Apr [abbreviated month]","",,"",5250,"Abr",1
5997,"ViewTranslation","May [abbreviated month]","",,"",5250,"Mai",1
5998,"ViewTranslation","Jun [abbreviated month]","",,"",5250,"Jun",1
5999,"ViewTranslation","Jul [abbreviated month]","",,"",5250,"Jul",1
6000,"ViewTranslation","Aug [abbreviated month]","",,"",5250,"Ago",1
6001,"ViewTranslation","Sep [abbreviated month]","",,"",5250,"Set",1
6002,"ViewTranslation","Oct [abbreviated month]","",,"",5250,"Out",1
6003,"ViewTranslation","Nov [abbreviated month]","",,"",5250,"Nov",1
6004,"ViewTranslation","Dec [abbreviated month]","",,"",5250,"Dez",1
6005,"ViewTranslation","Sunday [weekday]","",,"",5528,"Duminică",1
6006,"ViewTranslation","Monday [weekday]","",,"",5528,"Luni",1
6007,"ViewTranslation","Tuesday [weekday]","",,"",5528,"Marţi",1
6008,"ViewTranslation","Wednesday [weekday]","",,"",5528,"Miercuri",1
6009,"ViewTranslation","Thursday [weekday]","",,"",5528,"Joi",1
6010,"ViewTranslation","Friday [weekday]","",,"",5528,"Vineri",1
6011,"ViewTranslation","Saturday [weekday]","",,"",5528,"Sîmbătă",1
6012,"ViewTranslation","Sun [abbreviated weekday]","",,"",5528,"Du",1
6013,"ViewTranslation","Mon [abbreviated weekday]","",,"",5528,"Lu",1
6014,"ViewTranslation","Tue [abbreviated weekday]","",,"",5528,"Ma",1
6015,"ViewTranslation","Wed [abbreviated weekday]","",,"",5528,"Mi",1
6016,"ViewTranslation","Thu [abbreviated weekday]","",,"",5528,"Jo",1
6017,"ViewTranslation","Fri [abbreviated weekday]","",,"",5528,"Vi",1
6018,"ViewTranslation","Sat [abbreviated weekday]","",,"",5528,"Sî",1
6019,"ViewTranslation","January [month]","",,"",5528,"Ianuarie",1
6020,"ViewTranslation","February [month]","",,"",5528,"Februarie",1
6021,"ViewTranslation","March [month]","",,"",5528,"Martie",1
6022,"ViewTranslation","April [month]","",,"",5528,"Aprilie",1
6023,"ViewTranslation","May [month]","",,"",5528,"Mai",1
6024,"ViewTranslation","June [month]","",,"",5528,"Iunie",1
6025,"ViewTranslation","July [month]","",,"",5528,"Iulie",1
6026,"ViewTranslation","August [month]","",,"",5528,"August",1
6027,"ViewTranslation","September [month]","",,"",5528,"Septembrie",1
6028,"ViewTranslation","October [month]","",,"",5528,"Octombrie",1
6029,"ViewTranslation","November [month]","",,"",5528,"Noiembrie",1
6030,"ViewTranslation","December [month]","",,"",5528,"Decembrie",1
6031,"ViewTranslation","Jan [abbreviated month]","",,"",5528,"Ian",1
6032,"ViewTranslation","Feb [abbreviated month]","",,"",5528,"Feb",1
6033,"ViewTranslation","Mar [abbreviated month]","",,"",5528,"Mar",1
6034,"ViewTranslation","Apr [abbreviated month]","",,"",5528,"Apr",1
6035,"ViewTranslation","May [abbreviated month]","",,"",5528,"Mai",1
6036,"ViewTranslation","Jun [abbreviated month]","",,"",5528,"Iun",1
6037,"ViewTranslation","Jul [abbreviated month]","",,"",5528,"Iul",1
6038,"ViewTranslation","Aug [abbreviated month]","",,"",5528,"Aug",1
6039,"ViewTranslation","Sep [abbreviated month]","",,"",5528,"Sep",1
6040,"ViewTranslation","Oct [abbreviated month]","",,"",5528,"Oct",1
6041,"ViewTranslation","Nov [abbreviated month]","",,"",5528,"Nov",1
6042,"ViewTranslation","Dec [abbreviated month]","",,"",5528,"Dec",1
6043,"ViewTranslation","Sunday [weekday]","",,"",5819,"Sotnabeaivi",1
6044,"ViewTranslation","Monday [weekday]","",,"",5819,"Vuossárga",1
6045,"ViewTranslation","Tuesday [weekday]","",,"",5819,"Maŋŋebarga",1
6046,"ViewTranslation","Wednesday [weekday]","",,"",5819,"Gaskavahkku",1
6047,"ViewTranslation","Thursday [weekday]","",,"",5819,"Duorasdat",1
6048,"ViewTranslation","Friday [weekday]","",,"",5819,"Bearjadat",1
6049,"ViewTranslation","Saturday [weekday]","",,"",5819,"Lávvardat",1
6050,"ViewTranslation","Sun [abbreviated weekday]","",,"",5819,"Sotn",1
6051,"ViewTranslation","Mon [abbreviated weekday]","",,"",5819,"Vuos",1
6052,"ViewTranslation","Tue [abbreviated weekday]","",,"",5819,"Maŋ",1
6053,"ViewTranslation","Wed [abbreviated weekday]","",,"",5819,"Gask",1
6054,"ViewTranslation","Thu [abbreviated weekday]","",,"",5819,"Duor",1
6055,"ViewTranslation","Fri [abbreviated weekday]","",,"",5819,"Bear",1
6056,"ViewTranslation","Sat [abbreviated weekday]","",,"",5819,"Láv",1
6057,"ViewTranslation","January [month]","",,"",5819,"Ođđajagemánu",1
6058,"ViewTranslation","February [month]","",,"",5819,"Guovvamánu",1
6059,"ViewTranslation","March [month]","",,"",5819,"Njukčamánu",1
6060,"ViewTranslation","April [month]","",,"",5819,"Cuoŋománu",1
6061,"ViewTranslation","May [month]","",,"",5819,"Miessemánu",1
6062,"ViewTranslation","June [month]","",,"",5819,"Geassemánu",1
6063,"ViewTranslation","July [month]","",,"",5819,"Suoidnemánu",1
6064,"ViewTranslation","August [month]","",,"",5819,"Borgemánu",1
6065,"ViewTranslation","September [month]","",,"",5819,"Čakčamánu",1
6066,"ViewTranslation","October [month]","",,"",5819,"Golggotmánu",1
6067,"ViewTranslation","November [month]","",,"",5819,"Skábmamánu",1
6068,"ViewTranslation","December [month]","",,"",5819,"Juovlamánu",1
6069,"ViewTranslation","Jan [abbreviated month]","",,"",5819,"Ođđj",1
6070,"ViewTranslation","Feb [abbreviated month]","",,"",5819,"Guov",1
6071,"ViewTranslation","Mar [abbreviated month]","",,"",5819,"Njuk",1
6072,"ViewTranslation","Apr [abbreviated month]","",,"",5819,"Cuoŋ",1
6073,"ViewTranslation","May [abbreviated month]","",,"",5819,"Mies",1
6074,"ViewTranslation","Jun [abbreviated month]","",,"",5819,"Geas",1
6075,"ViewTranslation","Jul [abbreviated month]","",,"",5819,"Suoi",1
6076,"ViewTranslation","Aug [abbreviated month]","",,"",5819,"Borg",1
6077,"ViewTranslation","Sep [abbreviated month]","",,"",5819,"Čakč",1
6078,"ViewTranslation","Oct [abbreviated month]","",,"",5819,"Golg",1
6079,"ViewTranslation","Nov [abbreviated month]","",,"",5819,"Skáb",1
6080,"ViewTranslation","Dec [abbreviated month]","",,"",5819,"Juov",1
6081,"ViewTranslation","Sunday [weekday]","",,"",5728,"Sambata",1
6082,"ViewTranslation","Monday [weekday]","",,"",5728,"Sanyo",1
6083,"ViewTranslation","Tuesday [weekday]","",,"",5728,"Maakisanyo",1
6084,"ViewTranslation","Wednesday [weekday]","",,"",5728,"Roowe",1
6085,"ViewTranslation","Thursday [weekday]","",,"",5728,"Hamuse",1
6086,"ViewTranslation","Friday [weekday]","",,"",5728,"Arbe",1
6087,"ViewTranslation","Saturday [weekday]","",,"",5728,"Qidaame",1
6088,"ViewTranslation","Sun [abbreviated weekday]","",,"",5728,"Sam",1
6089,"ViewTranslation","Mon [abbreviated weekday]","",,"",5728,"San",1
6090,"ViewTranslation","Tue [abbreviated weekday]","",,"",5728,"Mak",1
6091,"ViewTranslation","Wed [abbreviated weekday]","",,"",5728,"Row",1
6092,"ViewTranslation","Thu [abbreviated weekday]","",,"",5728,"Ham",1
6093,"ViewTranslation","Fri [abbreviated weekday]","",,"",5728,"Arb",1
6094,"ViewTranslation","Sat [abbreviated weekday]","",,"",5728,"Qid",1
6095,"ViewTranslation","January [month]","",,"",5728,"January",1
6096,"ViewTranslation","February [month]","",,"",5728,"February",1
6097,"ViewTranslation","March [month]","",,"",5728,"March",1
6098,"ViewTranslation","April [month]","",,"",5728,"April",1
6099,"ViewTranslation","May [month]","",,"",5728,"May",1
6100,"ViewTranslation","June [month]","",,"",5728,"June",1
6101,"ViewTranslation","July [month]","",,"",5728,"July",1
6102,"ViewTranslation","August [month]","",,"",5728,"August",1
6103,"ViewTranslation","September [month]","",,"",5728,"September",1
6104,"ViewTranslation","October [month]","",,"",5728,"October",1
6105,"ViewTranslation","November [month]","",,"",5728,"November",1
6106,"ViewTranslation","December [month]","",,"",5728,"December",1
6107,"ViewTranslation","Jan [abbreviated month]","",,"",5728,"Jan",1
6108,"ViewTranslation","Feb [abbreviated month]","",,"",5728,"Feb",1
6109,"ViewTranslation","Mar [abbreviated month]","",,"",5728,"Mar",1
6110,"ViewTranslation","Apr [abbreviated month]","",,"",5728,"Apr",1
6111,"ViewTranslation","May [abbreviated month]","",,"",5728,"May",1
6112,"ViewTranslation","Jun [abbreviated month]","",,"",5728,"Jun",1
6113,"ViewTranslation","Jul [abbreviated month]","",,"",5728,"Jul",1
6114,"ViewTranslation","Aug [abbreviated month]","",,"",5728,"Aug",1
6115,"ViewTranslation","Sep [abbreviated month]","",,"",5728,"Sep",1
6116,"ViewTranslation","Oct [abbreviated month]","",,"",5728,"Oct",1
6117,"ViewTranslation","Nov [abbreviated month]","",,"",5728,"Nov",1
6118,"ViewTranslation","Dec [abbreviated month]","",,"",5728,"Dec",1
6119,"ViewTranslation","Sunday [weekday]","",,"",5800,"Nedeľa",1
6120,"ViewTranslation","Monday [weekday]","",,"",5800,"Pondelok",1
6121,"ViewTranslation","Tuesday [weekday]","",,"",5800,"Utorok",1
6122,"ViewTranslation","Wednesday [weekday]","",,"",5800,"Streda",1
6123,"ViewTranslation","Thursday [weekday]","",,"",5800,"Štvrtok",1
6124,"ViewTranslation","Friday [weekday]","",,"",5800,"Piatok",1
6125,"ViewTranslation","Saturday [weekday]","",,"",5800,"Sobota",1
6126,"ViewTranslation","Sun [abbreviated weekday]","",,"",5800,"Ne",1
6127,"ViewTranslation","Mon [abbreviated weekday]","",,"",5800,"Po",1
6128,"ViewTranslation","Tue [abbreviated weekday]","",,"",5800,"Ut",1
6129,"ViewTranslation","Wed [abbreviated weekday]","",,"",5800,"St",1
6130,"ViewTranslation","Thu [abbreviated weekday]","",,"",5800,"Št",1
6131,"ViewTranslation","Fri [abbreviated weekday]","",,"",5800,"Pi",1
6132,"ViewTranslation","Sat [abbreviated weekday]","",,"",5800,"So",1
6133,"ViewTranslation","January [month]","",,"",5800,"Január",1
6134,"ViewTranslation","February [month]","",,"",5800,"Február",1
6135,"ViewTranslation","March [month]","",,"",5800,"Marec",1
6136,"ViewTranslation","April [month]","",,"",5800,"Apríl",1
6137,"ViewTranslation","May [month]","",,"",5800,"Máj",1
6138,"ViewTranslation","June [month]","",,"",5800,"Jún",1
6139,"ViewTranslation","July [month]","",,"",5800,"Júl",1
6140,"ViewTranslation","August [month]","",,"",5800,"August",1
6141,"ViewTranslation","September [month]","",,"",5800,"September",1
6142,"ViewTranslation","October [month]","",,"",5800,"Október",1
6143,"ViewTranslation","November [month]","",,"",5800,"November",1
6144,"ViewTranslation","December [month]","",,"",5800,"December",1
6145,"ViewTranslation","Jan [abbreviated month]","",,"",5800,"Jan",1
6146,"ViewTranslation","Feb [abbreviated month]","",,"",5800,"Feb",1
6147,"ViewTranslation","Mar [abbreviated month]","",,"",5800,"Mar",1
6148,"ViewTranslation","Apr [abbreviated month]","",,"",5800,"Apr",1
6149,"ViewTranslation","May [abbreviated month]","",,"",5800,"Máj",1
6150,"ViewTranslation","Jun [abbreviated month]","",,"",5800,"Jún",1
6151,"ViewTranslation","Jul [abbreviated month]","",,"",5800,"Júl",1
6152,"ViewTranslation","Aug [abbreviated month]","",,"",5800,"Aug",1
6153,"ViewTranslation","Sep [abbreviated month]","",,"",5800,"Sep",1
6154,"ViewTranslation","Oct [abbreviated month]","",,"",5800,"Okt",1
6155,"ViewTranslation","Nov [abbreviated month]","",,"",5800,"Nov",1
6156,"ViewTranslation","Dec [abbreviated month]","",,"",5800,"Dec",1
6157,"ViewTranslation","Sunday [weekday]","",,"",5810,"Nedelja",1
6158,"ViewTranslation","Monday [weekday]","",,"",5810,"Ponedeljek",1
6159,"ViewTranslation","Tuesday [weekday]","",,"",5810,"Torek",1
6160,"ViewTranslation","Wednesday [weekday]","",,"",5810,"Sreda",1
6161,"ViewTranslation","Thursday [weekday]","",,"",5810,"Četrtek",1
6162,"ViewTranslation","Friday [weekday]","",,"",5810,"Petek",1
6163,"ViewTranslation","Saturday [weekday]","",,"",5810,"Sobota",1
6164,"ViewTranslation","Sun [abbreviated weekday]","",,"",5810,"Ned",1
6165,"ViewTranslation","Mon [abbreviated weekday]","",,"",5810,"Pon",1
6166,"ViewTranslation","Tue [abbreviated weekday]","",,"",5810,"Tor",1
6167,"ViewTranslation","Wed [abbreviated weekday]","",,"",5810,"Sre",1
6168,"ViewTranslation","Thu [abbreviated weekday]","",,"",5810,"Čet",1
6169,"ViewTranslation","Fri [abbreviated weekday]","",,"",5810,"Pet",1
6170,"ViewTranslation","Sat [abbreviated weekday]","",,"",5810,"Sob",1
6171,"ViewTranslation","January [month]","",,"",5810,"Januar",1
6172,"ViewTranslation","February [month]","",,"",5810,"Februar",1
6173,"ViewTranslation","March [month]","",,"",5810,"Marec",1
6174,"ViewTranslation","April [month]","",,"",5810,"April",1
6175,"ViewTranslation","May [month]","",,"",5810,"Maj",1
6176,"ViewTranslation","June [month]","",,"",5810,"Junij",1
6177,"ViewTranslation","July [month]","",,"",5810,"Julij",1
6178,"ViewTranslation","August [month]","",,"",5810,"Avgust",1
6179,"ViewTranslation","September [month]","",,"",5810,"September",1
6180,"ViewTranslation","October [month]","",,"",5810,"Oktober",1
6181,"ViewTranslation","November [month]","",,"",5810,"November",1
6182,"ViewTranslation","December [month]","",,"",5810,"December",1
6183,"ViewTranslation","Jan [abbreviated month]","",,"",5810,"Jan",1
6184,"ViewTranslation","Feb [abbreviated month]","",,"",5810,"Feb",1
6185,"ViewTranslation","Mar [abbreviated month]","",,"",5810,"Mar",1
6186,"ViewTranslation","Apr [abbreviated month]","",,"",5810,"Apr",1
6187,"ViewTranslation","May [abbreviated month]","",,"",5810,"Maj",1
6188,"ViewTranslation","Jun [abbreviated month]","",,"",5810,"Jun",1
6189,"ViewTranslation","Jul [abbreviated month]","",,"",5810,"Jul",1
6190,"ViewTranslation","Aug [abbreviated month]","",,"",5810,"Avg",1
6191,"ViewTranslation","Sep [abbreviated month]","",,"",5810,"Sep",1
6192,"ViewTranslation","Oct [abbreviated month]","",,"",5810,"Okt",1
6193,"ViewTranslation","Nov [abbreviated month]","",,"",5810,"Nov",1
6194,"ViewTranslation","Dec [abbreviated month]","",,"",5810,"Dec",1
6195,"ViewTranslation","Sunday [weekday]","",,"",5876,"Axad",1
6196,"ViewTranslation","Monday [weekday]","",,"",5876,"Isniin",1
6197,"ViewTranslation","Tuesday [weekday]","",,"",5876,"Salaaso",1
6198,"ViewTranslation","Wednesday [weekday]","",,"",5876,"Arbaco",1
6199,"ViewTranslation","Thursday [weekday]","",,"",5876,"Khamiis",1
6200,"ViewTranslation","Friday [weekday]","",,"",5876,"Jimco",1
6201,"ViewTranslation","Saturday [weekday]","",,"",5876,"Sabti",1
6202,"ViewTranslation","Sun [abbreviated weekday]","",,"",5876,"Axa",1
6203,"ViewTranslation","Mon [abbreviated weekday]","",,"",5876,"Isn",1
6204,"ViewTranslation","Tue [abbreviated weekday]","",,"",5876,"Sal",1
6205,"ViewTranslation","Wed [abbreviated weekday]","",,"",5876,"Arb",1
6206,"ViewTranslation","Thu [abbreviated weekday]","",,"",5876,"Kha",1
6207,"ViewTranslation","Fri [abbreviated weekday]","",,"",5876,"Jim",1
6208,"ViewTranslation","Sat [abbreviated weekday]","",,"",5876,"Sab",1
6209,"ViewTranslation","January [month]","",,"",5876,"Bisha koobaad",1
6210,"ViewTranslation","February [month]","",,"",5876,"Bisha labaad",1
6211,"ViewTranslation","March [month]","",,"",5876,"Bisha saddexaad",1
6212,"ViewTranslation","April [month]","",,"",5876,"Bisha afraad",1
6213,"ViewTranslation","May [month]","",,"",5876,"Bisha shanaad",1
6214,"ViewTranslation","June [month]","",,"",5876,"Bisha lixaad",1
6215,"ViewTranslation","July [month]","",,"",5876,"Bisha todobaad",1
6216,"ViewTranslation","August [month]","",,"",5876,"Bisha sideedaad",1
6217,"ViewTranslation","September [month]","",,"",5876,"Bisha sagaalaad",1
6218,"ViewTranslation","October [month]","",,"",5876,"Bisha tobnaad",1
6219,"ViewTranslation","November [month]","",,"",5876,"Bisha kow iyo tobnaad",1
6220,"ViewTranslation","December [month]","",,"",5876,"Bisha laba iyo tobnaad",1
6221,"ViewTranslation","Jan [abbreviated month]","",,"",5876,"Kob",1
6222,"ViewTranslation","Feb [abbreviated month]","",,"",5876,"Lab",1
6223,"ViewTranslation","Mar [abbreviated month]","",,"",5876,"Sad",1
6224,"ViewTranslation","Apr [abbreviated month]","",,"",5876,"Afr",1
6225,"ViewTranslation","May [abbreviated month]","",,"",5876,"Sha",1
6226,"ViewTranslation","Jun [abbreviated month]","",,"",5876,"Lix",1
6227,"ViewTranslation","Jul [abbreviated month]","",,"",5876,"Tod",1
6228,"ViewTranslation","Aug [abbreviated month]","",,"",5876,"Sid",1
6229,"ViewTranslation","Sep [abbreviated month]","",,"",5876,"Sag",1
6230,"ViewTranslation","Oct [abbreviated month]","",,"",5876,"Tob",1
6231,"ViewTranslation","Nov [abbreviated month]","",,"",5876,"Kit",1
6232,"ViewTranslation","Dec [abbreviated month]","",,"",5876,"Lit",1
6233,"ViewTranslation","Sunday [weekday]","",,"",5910,"E diel ",1
6234,"ViewTranslation","Monday [weekday]","",,"",5910,"E hënë ",1
6235,"ViewTranslation","Tuesday [weekday]","",,"",5910,"E martë ",1
6236,"ViewTranslation","Wednesday [weekday]","",,"",5910,"E mërkurë ",1
6237,"ViewTranslation","Thursday [weekday]","",,"",5910,"E enjte ",1
6238,"ViewTranslation","Friday [weekday]","",,"",5910,"E premte ",1
6239,"ViewTranslation","Saturday [weekday]","",,"",5910,"E shtunë ",1
6240,"ViewTranslation","Sun [abbreviated weekday]","",,"",5910,"Die ",1
6241,"ViewTranslation","Mon [abbreviated weekday]","",,"",5910,"Hën ",1
6242,"ViewTranslation","Tue [abbreviated weekday]","",,"",5910,"Mar ",1
6243,"ViewTranslation","Wed [abbreviated weekday]","",,"",5910,"Mër ",1
6244,"ViewTranslation","Thu [abbreviated weekday]","",,"",5910,"Enj ",1
6245,"ViewTranslation","Fri [abbreviated weekday]","",,"",5910,"Pre ",1
6246,"ViewTranslation","Sat [abbreviated weekday]","",,"",5910,"Sht ",1
6247,"ViewTranslation","January [month]","",,"",5910,"Janar",1
6248,"ViewTranslation","February [month]","",,"",5910,"Shkurt",1
6249,"ViewTranslation","March [month]","",,"",5910,"Mars",1
6250,"ViewTranslation","April [month]","",,"",5910,"Prill",1
6251,"ViewTranslation","May [month]","",,"",5910,"Maj",1
6252,"ViewTranslation","June [month]","",,"",5910,"Qershor",1
6253,"ViewTranslation","July [month]","",,"",5910,"Korrik",1
6254,"ViewTranslation","August [month]","",,"",5910,"Gusht",1
6255,"ViewTranslation","September [month]","",,"",5910,"Shtator",1
6256,"ViewTranslation","October [month]","",,"",5910,"Tetor",1
6257,"ViewTranslation","November [month]","",,"",5910,"Nëntor",1
6258,"ViewTranslation","December [month]","",,"",5910,"Dhjetor",1
6259,"ViewTranslation","Jan [abbreviated month]","",,"",5910,"Jan",1
6260,"ViewTranslation","Feb [abbreviated month]","",,"",5910,"Shk",1
6261,"ViewTranslation","Mar [abbreviated month]","",,"",5910,"Mar",1
6262,"ViewTranslation","Apr [abbreviated month]","",,"",5910,"Pri",1
6263,"ViewTranslation","May [abbreviated month]","",,"",5910,"Maj",1
6264,"ViewTranslation","Jun [abbreviated month]","",,"",5910,"Qer",1
6265,"ViewTranslation","Jul [abbreviated month]","",,"",5910,"Kor",1
6266,"ViewTranslation","Aug [abbreviated month]","",,"",5910,"Gsh",1
6267,"ViewTranslation","Sep [abbreviated month]","",,"",5910,"Sht",1
6268,"ViewTranslation","Oct [abbreviated month]","",,"",5910,"Tet",1
6269,"ViewTranslation","Nov [abbreviated month]","",,"",5910,"Nën",1
6270,"ViewTranslation","Dec [abbreviated month]","",,"",5910,"Dhj",1
6271,"ViewTranslation","Sunday [weekday]","",,"",5933,"Nedelja",1
6272,"ViewTranslation","Monday [weekday]","",,"",5933,"Ponedeljak",1
6273,"ViewTranslation","Tuesday [weekday]","",,"",5933,"Utorak",1
6274,"ViewTranslation","Wednesday [weekday]","",,"",5933,"Sreda",1
6275,"ViewTranslation","Thursday [weekday]","",,"",5933,"Četvrtak",1
6276,"ViewTranslation","Friday [weekday]","",,"",5933,"Petak",1
6277,"ViewTranslation","Saturday [weekday]","",,"",5933,"Subota",1
6278,"ViewTranslation","Sun [abbreviated weekday]","",,"",5933,"Ned",1
6279,"ViewTranslation","Mon [abbreviated weekday]","",,"",5933,"Pon",1
6280,"ViewTranslation","Tue [abbreviated weekday]","",,"",5933,"Uto",1
6281,"ViewTranslation","Wed [abbreviated weekday]","",,"",5933,"Sre",1
6282,"ViewTranslation","Thu [abbreviated weekday]","",,"",5933,"Čet",1
6283,"ViewTranslation","Fri [abbreviated weekday]","",,"",5933,"Pet",1
6284,"ViewTranslation","Sat [abbreviated weekday]","",,"",5933,"Sub",1
6285,"ViewTranslation","January [month]","",,"",5933,"Januar",1
6286,"ViewTranslation","February [month]","",,"",5933,"Februar",1
6287,"ViewTranslation","March [month]","",,"",5933,"Mart",1
6288,"ViewTranslation","April [month]","",,"",5933,"April",1
6289,"ViewTranslation","May [month]","",,"",5933,"Maj",1
6290,"ViewTranslation","June [month]","",,"",5933,"Juni",1
6291,"ViewTranslation","July [month]","",,"",5933,"Juli",1
6292,"ViewTranslation","August [month]","",,"",5933,"Avgust",1
6293,"ViewTranslation","September [month]","",,"",5933,"Septembar",1
6294,"ViewTranslation","October [month]","",,"",5933,"Oktobar",1
6295,"ViewTranslation","November [month]","",,"",5933,"Novembar",1
6296,"ViewTranslation","December [month]","",,"",5933,"Decembar",1
6297,"ViewTranslation","Jan [abbreviated month]","",,"",5933,"Jan",1
6298,"ViewTranslation","Feb [abbreviated month]","",,"",5933,"Feb",1
6299,"ViewTranslation","Mar [abbreviated month]","",,"",5933,"Mar",1
6300,"ViewTranslation","Apr [abbreviated month]","",,"",5933,"Apr",1
6301,"ViewTranslation","May [abbreviated month]","",,"",5933,"Maj",1
6302,"ViewTranslation","Jun [abbreviated month]","",,"",5933,"Jun",1
6303,"ViewTranslation","Jul [abbreviated month]","",,"",5933,"Jul",1
6304,"ViewTranslation","Aug [abbreviated month]","",,"",5933,"Avg",1
6305,"ViewTranslation","Sep [abbreviated month]","",,"",5933,"Sep",1
6306,"ViewTranslation","Oct [abbreviated month]","",,"",5933,"Okt",1
6307,"ViewTranslation","Nov [abbreviated month]","",,"",5933,"Nov",1
6308,"ViewTranslation","Dec [abbreviated month]","",,"",5933,"Dec",1
6309,"ViewTranslation","Sunday [weekday]","",,"",5882,"Sontaha",1
6310,"ViewTranslation","Monday [weekday]","",,"",5882,"Mmantaha",1
6311,"ViewTranslation","Tuesday [weekday]","",,"",5882,"Labobedi",1
6312,"ViewTranslation","Wednesday [weekday]","",,"",5882,"Laboraru",1
6313,"ViewTranslation","Thursday [weekday]","",,"",5882,"Labone",1
6314,"ViewTranslation","Friday [weekday]","",,"",5882,"Labohlane",1
6315,"ViewTranslation","Saturday [weekday]","",,"",5882,"Moqebelo",1
6316,"ViewTranslation","Sun [abbreviated weekday]","",,"",5882,"Son",1
6317,"ViewTranslation","Mon [abbreviated weekday]","",,"",5882,"Mma",1
6318,"ViewTranslation","Tue [abbreviated weekday]","",,"",5882,"Bed",1
6319,"ViewTranslation","Wed [abbreviated weekday]","",,"",5882,"Rar",1
6320,"ViewTranslation","Thu [abbreviated weekday]","",,"",5882,"Ne",1
6321,"ViewTranslation","Fri [abbreviated weekday]","",,"",5882,"Hla",1
6322,"ViewTranslation","Sat [abbreviated weekday]","",,"",5882,"Moq",1
6323,"ViewTranslation","January [month]","",,"",5882,"Phesekgong",1
6324,"ViewTranslation","February [month]","",,"",5882,"Hlakola",1
6325,"ViewTranslation","March [month]","",,"",5882,"Hlakubele",1
6326,"ViewTranslation","April [month]","",,"",5882,"Mmese",1
6327,"ViewTranslation","May [month]","",,"",5882,"Motsheanong",1
6328,"ViewTranslation","June [month]","",,"",5882,"Phupjane",1
6329,"ViewTranslation","July [month]","",,"",5882,"Phupu",1
6330,"ViewTranslation","August [month]","",,"",5882,"Phata",1
6331,"ViewTranslation","September [month]","",,"",5882,"Leotshe",1
6332,"ViewTranslation","October [month]","",,"",5882,"Mphalane",1
6333,"ViewTranslation","November [month]","",,"",5882,"Pundungwane",1
6334,"ViewTranslation","December [month]","",,"",5882,"Tshitwe",1
6335,"ViewTranslation","Jan [abbreviated month]","",,"",5882,"Phe",1
6336,"ViewTranslation","Feb [abbreviated month]","",,"",5882,"Kol",1
6337,"ViewTranslation","Mar [abbreviated month]","",,"",5882,"Ube",1
6338,"ViewTranslation","Apr [abbreviated month]","",,"",5882,"Mme",1
6339,"ViewTranslation","May [abbreviated month]","",,"",5882,"Mot",1
6340,"ViewTranslation","Jun [abbreviated month]","",,"",5882,"Jan",1
6341,"ViewTranslation","Jul [abbreviated month]","",,"",5882,"Upu",1
6342,"ViewTranslation","Aug [abbreviated month]","",,"",5882,"Pha",1
6343,"ViewTranslation","Sep [abbreviated month]","",,"",5882,"Leo",1
6344,"ViewTranslation","Oct [abbreviated month]","",,"",5882,"Mph",1
6345,"ViewTranslation","Nov [abbreviated month]","",,"",5882,"Pun",1
6346,"ViewTranslation","Dec [abbreviated month]","",,"",5882,"Tsh",1
6347,"ViewTranslation","Sunday [weekday]","",,"",6024,"Söndag",1
6348,"ViewTranslation","Monday [weekday]","",,"",6024,"Måndag",1
6349,"ViewTranslation","Tuesday [weekday]","",,"",6024,"Tisdag",1
6350,"ViewTranslation","Wednesday [weekday]","",,"",6024,"Onsdag",1
6351,"ViewTranslation","Thursday [weekday]","",,"",6024,"Torsdag",1
6352,"ViewTranslation","Friday [weekday]","",,"",6024,"Fredag",1
6353,"ViewTranslation","Saturday [weekday]","",,"",6024,"Lördag",1
6354,"ViewTranslation","Sun [abbreviated weekday]","",,"",6024,"Sön",1
6355,"ViewTranslation","Mon [abbreviated weekday]","",,"",6024,"Mån",1
6356,"ViewTranslation","Tue [abbreviated weekday]","",,"",6024,"Tis",1
6357,"ViewTranslation","Wed [abbreviated weekday]","",,"",6024,"Ons",1
6358,"ViewTranslation","Thu [abbreviated weekday]","",,"",6024,"Tor",1
6359,"ViewTranslation","Fri [abbreviated weekday]","",,"",6024,"Fre",1
6360,"ViewTranslation","Sat [abbreviated weekday]","",,"",6024,"Lör",1
6361,"ViewTranslation","January [month]","",,"",6024,"Januari",1
6362,"ViewTranslation","February [month]","",,"",6024,"Februari",1
6363,"ViewTranslation","March [month]","",,"",6024,"Mars",1
6364,"ViewTranslation","April [month]","",,"",6024,"April",1
6365,"ViewTranslation","May [month]","",,"",6024,"Maj",1
6366,"ViewTranslation","June [month]","",,"",6024,"Juni",1
6367,"ViewTranslation","July [month]","",,"",6024,"Juli",1
6368,"ViewTranslation","August [month]","",,"",6024,"Augusti",1
6369,"ViewTranslation","September [month]","",,"",6024,"September",1
6370,"ViewTranslation","October [month]","",,"",6024,"Oktober",1
6371,"ViewTranslation","November [month]","",,"",6024,"November",1
6372,"ViewTranslation","December [month]","",,"",6024,"December",1
6373,"ViewTranslation","Jan [abbreviated month]","",,"",6024,"Jan",1
6374,"ViewTranslation","Feb [abbreviated month]","",,"",6024,"Feb",1
6375,"ViewTranslation","Mar [abbreviated month]","",,"",6024,"Mar",1
6376,"ViewTranslation","Apr [abbreviated month]","",,"",6024,"Apr",1
6377,"ViewTranslation","May [abbreviated month]","",,"",6024,"Maj",1
6378,"ViewTranslation","Jun [abbreviated month]","",,"",6024,"Jun",1
6379,"ViewTranslation","Jul [abbreviated month]","",,"",6024,"Jul",1
6380,"ViewTranslation","Aug [abbreviated month]","",,"",6024,"Aug",1
6381,"ViewTranslation","Sep [abbreviated month]","",,"",6024,"Sep",1
6382,"ViewTranslation","Oct [abbreviated month]","",,"",6024,"Okt",1
6383,"ViewTranslation","Nov [abbreviated month]","",,"",6024,"Nov",1
6384,"ViewTranslation","Dec [abbreviated month]","",,"",6024,"Dec",1
6385,"ViewTranslation","Sunday [weekday]","",,"",6090,"ஞாயிறு",1
6386,"ViewTranslation","Monday [weekday]","",,"",6090,"திங்கள்",1
6387,"ViewTranslation","Tuesday [weekday]","",,"",6090,"செவ்வாய்",1
6388,"ViewTranslation","Wednesday [weekday]","",,"",6090,"புதன்",1
6389,"ViewTranslation","Thursday [weekday]","",,"",6090,"வியாழன்",1
6390,"ViewTranslation","Friday [weekday]","",,"",6090,"வெள்ளி",1
6391,"ViewTranslation","Saturday [weekday]","",,"",6090,"சனி",1
6392,"ViewTranslation","Sun [abbreviated weekday]","",,"",6090,"ஞ",1
6393,"ViewTranslation","Mon [abbreviated weekday]","",,"",6090,"த",1
6394,"ViewTranslation","Tue [abbreviated weekday]","",,"",6090,"ச",1
6395,"ViewTranslation","Wed [abbreviated weekday]","",,"",6090,"ப",1
6396,"ViewTranslation","Thu [abbreviated weekday]","",,"",6090,"வ",1
6397,"ViewTranslation","Fri [abbreviated weekday]","",,"",6090,"வ",1
6398,"ViewTranslation","Sat [abbreviated weekday]","",,"",6090,"ச",1
6399,"ViewTranslation","January [month]","",,"",6090,"ஜனவரி",1
6400,"ViewTranslation","February [month]","",,"",6090,"பெப்ரவரி",1
6401,"ViewTranslation","March [month]","",,"",6090,"மார்ச்",1
6402,"ViewTranslation","April [month]","",,"",6090,"ஏப்ரல்",1
6403,"ViewTranslation","May [month]","",,"",6090,"மே",1
6404,"ViewTranslation","June [month]","",,"",6090,"ஜூன்",1
6405,"ViewTranslation","July [month]","",,"",6090,"ஜூலை",1
6406,"ViewTranslation","August [month]","",,"",6090,"ஆகஸ்ட்",1
6407,"ViewTranslation","September [month]","",,"",6090,"செப்டம்பர்",1
6408,"ViewTranslation","October [month]","",,"",6090,"அக்டோபர்",1
6409,"ViewTranslation","November [month]","",,"",6090,"நவம்பர்",1
6410,"ViewTranslation","December [month]","",,"",6090,"டிசம்பர்r",1
6411,"ViewTranslation","Jan [abbreviated month]","",,"",6090,"ஜனவரி",1
6412,"ViewTranslation","Feb [abbreviated month]","",,"",6090,"பெப்ரவரி",1
6413,"ViewTranslation","Mar [abbreviated month]","",,"",6090,"மார்ச்",1
6414,"ViewTranslation","Apr [abbreviated month]","",,"",6090,"ஏப்ரல்",1
6415,"ViewTranslation","May [abbreviated month]","",,"",6090,"மே",1
6416,"ViewTranslation","Jun [abbreviated month]","",,"",6090,"ஜூன்",1
6417,"ViewTranslation","Jul [abbreviated month]","",,"",6090,"ஜூலை",1
6418,"ViewTranslation","Aug [abbreviated month]","",,"",6090,"ஆகஸ்ட்",1
6419,"ViewTranslation","Sep [abbreviated month]","",,"",6090,"செப்டம்பர்",1
6420,"ViewTranslation","Oct [abbreviated month]","",,"",6090,"அக்டோபர்",1
6421,"ViewTranslation","Nov [abbreviated month]","",,"",6090,"நவம்பர்",1
6422,"ViewTranslation","Dec [abbreviated month]","",,"",6090,"டிசம்பர்r",1
6423,"ViewTranslation","Sunday [weekday]","",,"",6182,"ఆదివారం",1
6424,"ViewTranslation","Monday [weekday]","",,"",6182,"సోమవారం",1
6425,"ViewTranslation","Tuesday [weekday]","",,"",6182,"మంగళవారం",1
6426,"ViewTranslation","Wednesday [weekday]","",,"",6182,"బుధవారం",1
6427,"ViewTranslation","Thursday [weekday]","",,"",6182,"గురువారం",1
6428,"ViewTranslation","Friday [weekday]","",,"",6182,"శుక్రవారం",1
6429,"ViewTranslation","Saturday [weekday]","",,"",6182,"శనివారం",1
6430,"ViewTranslation","Sun [abbreviated weekday]","",,"",6182,"ఆది",1
6431,"ViewTranslation","Mon [abbreviated weekday]","",,"",6182,"సోమ",1
6432,"ViewTranslation","Tue [abbreviated weekday]","",,"",6182,"మంగళ",1
6433,"ViewTranslation","Wed [abbreviated weekday]","",,"",6182,"బుధ",1
6434,"ViewTranslation","Thu [abbreviated weekday]","",,"",6182,"గురు",1
6435,"ViewTranslation","Fri [abbreviated weekday]","",,"",6182,"శుక్ర",1
6436,"ViewTranslation","Sat [abbreviated weekday]","",,"",6182,"శని",1
6437,"ViewTranslation","January [month]","",,"",6182,"జనవరి",1
6438,"ViewTranslation","February [month]","",,"",6182,"ఫిబ్రవరి",1
6439,"ViewTranslation","March [month]","",,"",6182,"మార్చి",1
6440,"ViewTranslation","April [month]","",,"",6182,"ఏప్రిల్",1
6441,"ViewTranslation","May [month]","",,"",6182,"మే",1
6442,"ViewTranslation","June [month]","",,"",6182,"జూన్",1
6443,"ViewTranslation","July [month]","",,"",6182,"జూలై",1
6444,"ViewTranslation","August [month]","",,"",6182,"ఆగస్టు",1
6445,"ViewTranslation","September [month]","",,"",6182,"సెప్టెంబర్",1
6446,"ViewTranslation","October [month]","",,"",6182,"అక్టోబర్",1
6447,"ViewTranslation","November [month]","",,"",6182,"నవంబర్",1
6448,"ViewTranslation","December [month]","",,"",6182,"డిసెంబర్",1
6449,"ViewTranslation","Jan [abbreviated month]","",,"",6182,"జనవరి",1
6450,"ViewTranslation","Feb [abbreviated month]","",,"",6182,"ఫిబ్రవరి",1
6451,"ViewTranslation","Mar [abbreviated month]","",,"",6182,"మార్చి",1
6452,"ViewTranslation","Apr [abbreviated month]","",,"",6182,"ఏప్రిల్",1
6453,"ViewTranslation","May [abbreviated month]","",,"",6182,"మే",1
6454,"ViewTranslation","Jun [abbreviated month]","",,"",6182,"జూన్",1
6455,"ViewTranslation","Jul [abbreviated month]","",,"",6182,"జూలై",1
6456,"ViewTranslation","Aug [abbreviated month]","",,"",6182,"ఆగస్టు",1
6457,"ViewTranslation","Sep [abbreviated month]","",,"",6182,"సెప్టెంబర్",1
6458,"ViewTranslation","Oct [abbreviated month]","",,"",6182,"అక్టోబర్",1
6459,"ViewTranslation","Nov [abbreviated month]","",,"",6182,"నవంబర్",1
6460,"ViewTranslation","Dec [abbreviated month]","",,"",6182,"డిసెంబర్",1
6461,"ViewTranslation","Sunday [weekday]","",,"",6210,"Воскресенье",1
6462,"ViewTranslation","Monday [weekday]","",,"",6210,"Понедельник",1
6463,"ViewTranslation","Tuesday [weekday]","",,"",6210,"Вторник",1
6464,"ViewTranslation","Wednesday [weekday]","",,"",6210,"Среда",1
6465,"ViewTranslation","Thursday [weekday]","",,"",6210,"Четверг",1
6466,"ViewTranslation","Friday [weekday]","",,"",6210,"Пятница",1
6467,"ViewTranslation","Saturday [weekday]","",,"",6210,"Суббота",1
6468,"ViewTranslation","Sun [abbreviated weekday]","",,"",6210,"Вск",1
6469,"ViewTranslation","Mon [abbreviated weekday]","",,"",6210,"Пнд",1
6470,"ViewTranslation","Tue [abbreviated weekday]","",,"",6210,"Втр",1
6471,"ViewTranslation","Wed [abbreviated weekday]","",,"",6210,"Срд",1
6472,"ViewTranslation","Thu [abbreviated weekday]","",,"",6210,"Чтв",1
6473,"ViewTranslation","Fri [abbreviated weekday]","",,"",6210,"Птн",1
6474,"ViewTranslation","Sat [abbreviated weekday]","",,"",6210,"Сбт",1
6475,"ViewTranslation","January [month]","",,"",6210,"Января",1
6476,"ViewTranslation","February [month]","",,"",6210,"Февраля",1
6477,"ViewTranslation","March [month]","",,"",6210,"Марта",1
6478,"ViewTranslation","April [month]","",,"",6210,"Апреля",1
6479,"ViewTranslation","May [month]","",,"",6210,"Мая",1
6480,"ViewTranslation","June [month]","",,"",6210,"Июня",1
6481,"ViewTranslation","July [month]","",,"",6210,"Июля",1
6482,"ViewTranslation","August [month]","",,"",6210,"Августа",1
6483,"ViewTranslation","September [month]","",,"",6210,"Сентября",1
6484,"ViewTranslation","October [month]","",,"",6210,"Октября",1
6485,"ViewTranslation","November [month]","",,"",6210,"Ноября",1
6486,"ViewTranslation","December [month]","",,"",6210,"Декабря",1
6487,"ViewTranslation","Jan [abbreviated month]","",,"",6210,"Янв",1
6488,"ViewTranslation","Feb [abbreviated month]","",,"",6210,"Фев",1
6489,"ViewTranslation","Mar [abbreviated month]","",,"",6210,"Мар",1
6490,"ViewTranslation","Apr [abbreviated month]","",,"",6210,"Апр",1
6491,"ViewTranslation","May [abbreviated month]","",,"",6210,"Май",1
6492,"ViewTranslation","Jun [abbreviated month]","",,"",6210,"Июн",1
6493,"ViewTranslation","Jul [abbreviated month]","",,"",6210,"Июл",1
6494,"ViewTranslation","Aug [abbreviated month]","",,"",6210,"Авг",1
6495,"ViewTranslation","Sep [abbreviated month]","",,"",6210,"Сен",1
6496,"ViewTranslation","Oct [abbreviated month]","",,"",6210,"Окт",1
6497,"ViewTranslation","Nov [abbreviated month]","",,"",6210,"Ноя",1
6498,"ViewTranslation","Dec [abbreviated month]","",,"",6210,"Дек",1
6499,"ViewTranslation","Sunday [weekday]","",,"",6223,"อาทิตย์",1
6500,"ViewTranslation","Monday [weekday]","",,"",6223,"จันทร์",1
6501,"ViewTranslation","Tuesday [weekday]","",,"",6223,"อังคาร",1
6502,"ViewTranslation","Wednesday [weekday]","",,"",6223,"พุธ",1
6503,"ViewTranslation","Thursday [weekday]","",,"",6223,"พฤหัสบดี",1
6504,"ViewTranslation","Friday [weekday]","",,"",6223,"ศุกร์",1
6505,"ViewTranslation","Saturday [weekday]","",,"",6223,"เสาร์",1
6506,"ViewTranslation","Sun [abbreviated weekday]","",,"",6223,"อา.",1
6507,"ViewTranslation","Mon [abbreviated weekday]","",,"",6223,"จ.",1
6508,"ViewTranslation","Tue [abbreviated weekday]","",,"",6223,"อ.",1
6509,"ViewTranslation","Wed [abbreviated weekday]","",,"",6223,"พ.",1
6510,"ViewTranslation","Thu [abbreviated weekday]","",,"",6223,"พฤ.",1
6511,"ViewTranslation","Fri [abbreviated weekday]","",,"",6223,"ศ.",1
6512,"ViewTranslation","Sat [abbreviated weekday]","",,"",6223,"ส.",1
6513,"ViewTranslation","January [month]","",,"",6223,"มกราคม",1
6514,"ViewTranslation","February [month]","",,"",6223,"กุมภาพันธ์",1
6515,"ViewTranslation","March [month]","",,"",6223,"มีนาคม",1
6516,"ViewTranslation","April [month]","",,"",6223,"เมษายน",1
6517,"ViewTranslation","May [month]","",,"",6223,"พฤษภาคม",1
6518,"ViewTranslation","June [month]","",,"",6223,"มิถุนายน",1
6519,"ViewTranslation","July [month]","",,"",6223,"กรกฎาคม",1
6520,"ViewTranslation","August [month]","",,"",6223,"สิงหาคม",1
6521,"ViewTranslation","September [month]","",,"",6223,"กันยายน",1
6522,"ViewTranslation","October [month]","",,"",6223,"ตุลาคม",1
6523,"ViewTranslation","November [month]","",,"",6223,"พฤศจิกายน",1
6524,"ViewTranslation","December [month]","",,"",6223,"ธันวาคม",1
6525,"ViewTranslation","Jan [abbreviated month]","",,"",6223,"ม.ค.",1
6526,"ViewTranslation","Feb [abbreviated month]","",,"",6223,"ก.พ.",1
6527,"ViewTranslation","Mar [abbreviated month]","",,"",6223,"มี.ค.",1
6528,"ViewTranslation","Apr [abbreviated month]","",,"",6223,"เม.ย.",1
6529,"ViewTranslation","May [abbreviated month]","",,"",6223,"พ.ค.",1
6530,"ViewTranslation","Jun [abbreviated month]","",,"",6223,"มิ.ย.",1
6531,"ViewTranslation","Jul [abbreviated month]","",,"",6223,"ก.ค.",1
6532,"ViewTranslation","Aug [abbreviated month]","",,"",6223,"ส.ค.",1
6533,"ViewTranslation","Sep [abbreviated month]","",,"",6223,"ก.ย.",1
6534,"ViewTranslation","Oct [abbreviated month]","",,"",6223,"ต.ค.",1
6535,"ViewTranslation","Nov [abbreviated month]","",,"",6223,"พ.ย.",1
6536,"ViewTranslation","Dec [abbreviated month]","",,"",6223,"ธ.ค.",1
6537,"ViewTranslation","Sunday [weekday]","",,"",6249,"ሰንበት ዓባይ",1
6538,"ViewTranslation","Monday [weekday]","",,"",6249,"ሰኖ",1
6539,"ViewTranslation","Tuesday [weekday]","",,"",6249,"ታላሸኖ",1
6540,"ViewTranslation","Wednesday [weekday]","",,"",6249,"ኣረርባዓ",1
6541,"ViewTranslation","Thursday [weekday]","",,"",6249,"ከሚሽ",1
6542,"ViewTranslation","Friday [weekday]","",,"",6249,"ጅምዓት",1
6543,"ViewTranslation","Saturday [weekday]","",,"",6249,"ሰንበት ንኢሽ",1
6544,"ViewTranslation","Sun [abbreviated weekday]","",,"",6249,"ሰ/ዓ",1
6545,"ViewTranslation","Mon [abbreviated weekday]","",,"",6249,"ሰኖ ",1
6546,"ViewTranslation","Tue [abbreviated weekday]","",,"",6249,"ታላሸ",1
6547,"ViewTranslation","Wed [abbreviated weekday]","",,"",6249,"ኣረር",1
6548,"ViewTranslation","Thu [abbreviated weekday]","",,"",6249,"ከሚሽ",1
6549,"ViewTranslation","Fri [abbreviated weekday]","",,"",6249,"ጅምዓ",1
6550,"ViewTranslation","Sat [abbreviated weekday]","",,"",6249,"ሰ/ን",1
6551,"ViewTranslation","January [month]","",,"",6249,"ጥሪ",1
6552,"ViewTranslation","February [month]","",,"",6249,"ለካቲት",1
6553,"ViewTranslation","March [month]","",,"",6249,"መጋቢት",1
6554,"ViewTranslation","April [month]","",,"",6249,"ሚያዝያ",1
6555,"ViewTranslation","May [month]","",,"",6249,"ግንቦት",1
6556,"ViewTranslation","June [month]","",,"",6249,"ሰነ",1
6557,"ViewTranslation","July [month]","",,"",6249,"ሓምለ",1
6558,"ViewTranslation","August [month]","",,"",6249,"ነሓሰ",1
6559,"ViewTranslation","September [month]","",,"",6249,"መስከረም",1
6560,"ViewTranslation","October [month]","",,"",6249,"ጥቅምቲ",1
6561,"ViewTranslation","November [month]","",,"",6249,"ሕዳር",1
6562,"ViewTranslation","December [month]","",,"",6249,"ታሕሳስ",1
6563,"ViewTranslation","Jan [abbreviated month]","",,"",6249,"ጥሪ ",1
6564,"ViewTranslation","Feb [abbreviated month]","",,"",6249,"ለካቲ",1
6565,"ViewTranslation","Mar [abbreviated month]","",,"",6249,"መጋቢ",1
6566,"ViewTranslation","Apr [abbreviated month]","",,"",6249,"ሚያዝ",1
6567,"ViewTranslation","May [abbreviated month]","",,"",6249,"ግንቦ",1
6568,"ViewTranslation","Jun [abbreviated month]","",,"",6249,"ሰነ ",1
6569,"ViewTranslation","Jul [abbreviated month]","",,"",6249,"ሓምለ",1
6570,"ViewTranslation","Aug [abbreviated month]","",,"",6249,"ነሓሰ",1
6571,"ViewTranslation","Sep [abbreviated month]","",,"",6249,"መስከ",1
6572,"ViewTranslation","Oct [abbreviated month]","",,"",6249,"ጥቅም",1
6573,"ViewTranslation","Nov [abbreviated month]","",,"",6249,"ሕዳር",1
6574,"ViewTranslation","Dec [abbreviated month]","",,"",6249,"ታሕሳ",1
6575,"ViewTranslation","Sunday [weekday]","",,"",6211,"Linggo",1
6576,"ViewTranslation","Monday [weekday]","",,"",6211,"Lunes",1
6577,"ViewTranslation","Tuesday [weekday]","",,"",6211,"Martes",1
6578,"ViewTranslation","Wednesday [weekday]","",,"",6211,"Miyerkoles",1
6579,"ViewTranslation","Thursday [weekday]","",,"",6211,"Huwebes",1
6580,"ViewTranslation","Friday [weekday]","",,"",6211,"Biyernes",1
6581,"ViewTranslation","Saturday [weekday]","",,"",6211,"Sabado",1
6582,"ViewTranslation","Sun [abbreviated weekday]","",,"",6211,"Lin",1
6583,"ViewTranslation","Mon [abbreviated weekday]","",,"",6211,"Lun",1
6584,"ViewTranslation","Tue [abbreviated weekday]","",,"",6211,"Mar",1
6585,"ViewTranslation","Wed [abbreviated weekday]","",,"",6211,"Miy",1
6586,"ViewTranslation","Thu [abbreviated weekday]","",,"",6211,"Huw",1
6587,"ViewTranslation","Fri [abbreviated weekday]","",,"",6211,"Biy",1
6588,"ViewTranslation","Sat [abbreviated weekday]","",,"",6211,"Sab",1
6589,"ViewTranslation","January [month]","",,"",6211,"Enero",1
6590,"ViewTranslation","February [month]","",,"",6211,"Pebrero",1
6591,"ViewTranslation","March [month]","",,"",6211,"Marso",1
6592,"ViewTranslation","April [month]","",,"",6211,"Abril",1
6593,"ViewTranslation","May [month]","",,"",6211,"Mayo",1
6594,"ViewTranslation","June [month]","",,"",6211,"Hunyo",1
6595,"ViewTranslation","July [month]","",,"",6211,"Hulyo",1
6596,"ViewTranslation","August [month]","",,"",6211,"Agosto",1
6597,"ViewTranslation","September [month]","",,"",6211,"Septiyembre",1
6598,"ViewTranslation","October [month]","",,"",6211,"Oktubre",1
6599,"ViewTranslation","November [month]","",,"",6211,"Nobiyembre",1
6600,"ViewTranslation","December [month]","",,"",6211,"Disyembre",1
6601,"ViewTranslation","Jan [abbreviated month]","",,"",6211,"Ene",1
6602,"ViewTranslation","Feb [abbreviated month]","",,"",6211,"Peb",1
6603,"ViewTranslation","Mar [abbreviated month]","",,"",6211,"Mar",1
6604,"ViewTranslation","Apr [abbreviated month]","",,"",6211,"Abr",1
6605,"ViewTranslation","May [abbreviated month]","",,"",6211,"May",1
6606,"ViewTranslation","Jun [abbreviated month]","",,"",6211,"Hun",1
6607,"ViewTranslation","Jul [abbreviated month]","",,"",6211,"Hul",1
6608,"ViewTranslation","Aug [abbreviated month]","",,"",6211,"Ago",1
6609,"ViewTranslation","Sep [abbreviated month]","",,"",6211,"Sep",1
6610,"ViewTranslation","Oct [abbreviated month]","",,"",6211,"Okt",1
6611,"ViewTranslation","Nov [abbreviated month]","",,"",6211,"Nob",1
6612,"ViewTranslation","Dec [abbreviated month]","",,"",6211,"Dis",1
6613,"ViewTranslation","Sunday [weekday]","",,"",6519,"Pazar",1
6614,"ViewTranslation","Monday [weekday]","",,"",6519,"Pazartesi",1
6615,"ViewTranslation","Tuesday [weekday]","",,"",6519,"Salı",1
6616,"ViewTranslation","Wednesday [weekday]","",,"",6519,"Çarşamba",1
6617,"ViewTranslation","Thursday [weekday]","",,"",6519,"Perşembe",1
6618,"ViewTranslation","Friday [weekday]","",,"",6519,"Cuma",1
6619,"ViewTranslation","Saturday [weekday]","",,"",6519,"Cumartesi",1
6620,"ViewTranslation","Sun [abbreviated weekday]","",,"",6519,"Paz",1
6621,"ViewTranslation","Mon [abbreviated weekday]","",,"",6519,"Pzt",1
6622,"ViewTranslation","Tue [abbreviated weekday]","",,"",6519,"Sal",1
6623,"ViewTranslation","Wed [abbreviated weekday]","",,"",6519,"Çrş",1
6624,"ViewTranslation","Thu [abbreviated weekday]","",,"",6519,"Prş",1
6625,"ViewTranslation","Fri [abbreviated weekday]","",,"",6519,"Cum",1
6626,"ViewTranslation","Sat [abbreviated weekday]","",,"",6519,"Cts",1
6627,"ViewTranslation","January [month]","",,"",6519,"Ocak",1
6628,"ViewTranslation","February [month]","",,"",6519,"Şubat",1
6629,"ViewTranslation","March [month]","",,"",6519,"Mart",1
6630,"ViewTranslation","April [month]","",,"",6519,"Nisan",1
6631,"ViewTranslation","May [month]","",,"",6519,"Mayıs",1
6632,"ViewTranslation","June [month]","",,"",6519,"Haziran",1
6633,"ViewTranslation","July [month]","",,"",6519,"Temmuz",1
6634,"ViewTranslation","August [month]","",,"",6519,"Ağustos",1
6635,"ViewTranslation","September [month]","",,"",6519,"Eylül",1
6636,"ViewTranslation","October [month]","",,"",6519,"Ekim",1
6637,"ViewTranslation","November [month]","",,"",6519,"Kasım",1
6638,"ViewTranslation","December [month]","",,"",6519,"Aralık",1
6639,"ViewTranslation","Jan [abbreviated month]","",,"",6519,"Oca",1
6640,"ViewTranslation","Feb [abbreviated month]","",,"",6519,"Şub",1
6641,"ViewTranslation","Mar [abbreviated month]","",,"",6519,"Mar",1
6642,"ViewTranslation","Apr [abbreviated month]","",,"",6519,"Nis",1
6643,"ViewTranslation","May [abbreviated month]","",,"",6519,"May",1
6644,"ViewTranslation","Jun [abbreviated month]","",,"",6519,"Haz",1
6645,"ViewTranslation","Jul [abbreviated month]","",,"",6519,"Tem",1
6646,"ViewTranslation","Aug [abbreviated month]","",,"",6519,"Ağu",1
6647,"ViewTranslation","Sep [abbreviated month]","",,"",6519,"Eyl",1
6648,"ViewTranslation","Oct [abbreviated month]","",,"",6519,"Eki",1
6649,"ViewTranslation","Nov [abbreviated month]","",,"",6519,"Kas",1
6650,"ViewTranslation","Dec [abbreviated month]","",,"",6519,"Ara",1
6651,"ViewTranslation","Sunday [weekday]","",,"",6097,"Якшәмбе",1
6652,"ViewTranslation","Monday [weekday]","",,"",6097,"Дышәмбе",1
6653,"ViewTranslation","Tuesday [weekday]","",,"",6097,"Сишәмбе",1
6654,"ViewTranslation","Wednesday [weekday]","",,"",6097,"Чәршәәмбе",1
6655,"ViewTranslation","Thursday [weekday]","",,"",6097,"Пәнҗешмбе",1
6656,"ViewTranslation","Friday [weekday]","",,"",6097,"Җомга",1
6657,"ViewTranslation","Saturday [weekday]","",,"",6097,"Шимбә",1
6658,"ViewTranslation","Sun [abbreviated weekday]","",,"",6097,"Якш",1
6659,"ViewTranslation","Mon [abbreviated weekday]","",,"",6097,"Дыш",1
6660,"ViewTranslation","Tue [abbreviated weekday]","",,"",6097,"Сиш",1
6661,"ViewTranslation","Wed [abbreviated weekday]","",,"",6097,"Чәрш",1
6662,"ViewTranslation","Thu [abbreviated weekday]","",,"",6097,"Пәнҗ",1
6663,"ViewTranslation","Fri [abbreviated weekday]","",,"",6097,"Җом",1
6664,"ViewTranslation","Sat [abbreviated weekday]","",,"",6097,"Шим",1
6665,"ViewTranslation","January [month]","",,"",6097,"Января",1
6666,"ViewTranslation","February [month]","",,"",6097,"Февраля",1
6667,"ViewTranslation","March [month]","",,"",6097,"Марта",1
6668,"ViewTranslation","April [month]","",,"",6097,"Апреля",1
6669,"ViewTranslation","May [month]","",,"",6097,"Мая",1
6670,"ViewTranslation","June [month]","",,"",6097,"Июня",1
6671,"ViewTranslation","July [month]","",,"",6097,"Июля",1
6672,"ViewTranslation","August [month]","",,"",6097,"Августа",1
6673,"ViewTranslation","September [month]","",,"",6097,"Сентября",1
6674,"ViewTranslation","October [month]","",,"",6097,"Октября",1
6675,"ViewTranslation","November [month]","",,"",6097,"Ноября",1
6676,"ViewTranslation","December [month]","",,"",6097,"Декабря",1
6677,"ViewTranslation","Jan [abbreviated month]","",,"",6097,"Янв",1
6678,"ViewTranslation","Feb [abbreviated month]","",,"",6097,"Фев",1
6679,"ViewTranslation","Mar [abbreviated month]","",,"",6097,"Мар",1
6680,"ViewTranslation","Apr [abbreviated month]","",,"",6097,"Апр",1
6681,"ViewTranslation","May [abbreviated month]","",,"",6097,"Май",1
6682,"ViewTranslation","Jun [abbreviated month]","",,"",6097,"Июн",1
6683,"ViewTranslation","Jul [abbreviated month]","",,"",6097,"Июл",1
6684,"ViewTranslation","Aug [abbreviated month]","",,"",6097,"Авг",1
6685,"ViewTranslation","Sep [abbreviated month]","",,"",6097,"Сен",1
6686,"ViewTranslation","Oct [abbreviated month]","",,"",6097,"Окт",1
6687,"ViewTranslation","Nov [abbreviated month]","",,"",6097,"Ноя",1
6688,"ViewTranslation","Dec [abbreviated month]","",,"",6097,"Дек",1
6689,"ViewTranslation","Sunday [weekday]","",,"",6640,"Неділя",1
6690,"ViewTranslation","Monday [weekday]","",,"",6640,"Понеділок",1
6691,"ViewTranslation","Tuesday [weekday]","",,"",6640,"Вівторок",1
6692,"ViewTranslation","Wednesday [weekday]","",,"",6640,"Середа",1
6693,"ViewTranslation","Thursday [weekday]","",,"",6640,"Четвер",1
6694,"ViewTranslation","Friday [weekday]","",,"",6640,"П'ятниця",1
6695,"ViewTranslation","Saturday [weekday]","",,"",6640,"Субота",1
6696,"ViewTranslation","Sun [abbreviated weekday]","",,"",6640,"Ндл",1
6697,"ViewTranslation","Mon [abbreviated weekday]","",,"",6640,"Пнд",1
6698,"ViewTranslation","Tue [abbreviated weekday]","",,"",6640,"Втр",1
6699,"ViewTranslation","Wed [abbreviated weekday]","",,"",6640,"Срд",1
6700,"ViewTranslation","Thu [abbreviated weekday]","",,"",6640,"Чтв",1
6701,"ViewTranslation","Fri [abbreviated weekday]","",,"",6640,"Птн",1
6702,"ViewTranslation","Sat [abbreviated weekday]","",,"",6640,"Сбт",1
6703,"ViewTranslation","January [month]","",,"",6640,"Січень",1
6704,"ViewTranslation","February [month]","",,"",6640,"Лютий",1
6705,"ViewTranslation","March [month]","",,"",6640,"Березень",1
6706,"ViewTranslation","April [month]","",,"",6640,"Квітень",1
6707,"ViewTranslation","May [month]","",,"",6640,"Травень",1
6708,"ViewTranslation","June [month]","",,"",6640,"Червень",1
6709,"ViewTranslation","July [month]","",,"",6640,"Липень",1
6710,"ViewTranslation","August [month]","",,"",6640,"Серпень",1
6711,"ViewTranslation","September [month]","",,"",6640,"Вересень",1
6712,"ViewTranslation","October [month]","",,"",6640,"Жовтень",1
6713,"ViewTranslation","November [month]","",,"",6640,"Листопад",1
6714,"ViewTranslation","December [month]","",,"",6640,"Грудень",1
6715,"ViewTranslation","Jan [abbreviated month]","",,"",6640,"Січ",1
6716,"ViewTranslation","Feb [abbreviated month]","",,"",6640,"Лют",1
6717,"ViewTranslation","Mar [abbreviated month]","",,"",6640,"Бер",1
6718,"ViewTranslation","Apr [abbreviated month]","",,"",6640,"Кві",1
6719,"ViewTranslation","May [abbreviated month]","",,"",6640,"Тра",1
6720,"ViewTranslation","Jun [abbreviated month]","",,"",6640,"Чер",1
6721,"ViewTranslation","Jul [abbreviated month]","",,"",6640,"Лип",1
6722,"ViewTranslation","Aug [abbreviated month]","",,"",6640,"Сер",1
6723,"ViewTranslation","Sep [abbreviated month]","",,"",6640,"Вер",1
6724,"ViewTranslation","Oct [abbreviated month]","",,"",6640,"Жов",1
6725,"ViewTranslation","Nov [abbreviated month]","",,"",6640,"Лис",1
6726,"ViewTranslation","Dec [abbreviated month]","",,"",6640,"Гру",1
6727,"ViewTranslation","Sunday [weekday]","",,"",6679,"اتوار",1
6728,"ViewTranslation","Monday [weekday]","",,"",6679,"پير",1
6729,"ViewTranslation","Tuesday [weekday]","",,"",6679,"منگل",1
6730,"ViewTranslation","Wednesday [weekday]","",,"",6679,"بدھ",1
6731,"ViewTranslation","Thursday [weekday]","",,"",6679,"جمعرات",1
6732,"ViewTranslation","Friday [weekday]","",,"",6679,"جمعه",1
6733,"ViewTranslation","Saturday [weekday]","",,"",6679,"هفته",1
6734,"ViewTranslation","Sun [abbreviated weekday]","",,"",6679,"اتوار",1
6735,"ViewTranslation","Mon [abbreviated weekday]","",,"",6679,"پير",1
6736,"ViewTranslation","Tue [abbreviated weekday]","",,"",6679,"منگل",1
6737,"ViewTranslation","Wed [abbreviated weekday]","",,"",6679,"بدھ",1
6738,"ViewTranslation","Thu [abbreviated weekday]","",,"",6679,"جمعرات",1
6739,"ViewTranslation","Fri [abbreviated weekday]","",,"",6679,"جمعه",1
6740,"ViewTranslation","Sat [abbreviated weekday]","",,"",6679,"هفته",1
6741,"ViewTranslation","January [month]","",,"",6679,"جنوري",1
6742,"ViewTranslation","February [month]","",,"",6679,"فروري",1
6743,"ViewTranslation","March [month]","",,"",6679,"مارچ",1
6744,"ViewTranslation","April [month]","",,"",6679,"اپريل",1
6745,"ViewTranslation","May [month]","",,"",6679,"مٓی",1
6746,"ViewTranslation","June [month]","",,"",6679,"جون",1
6747,"ViewTranslation","July [month]","",,"",6679,"جولاي",1
6748,"ViewTranslation","August [month]","",,"",6679,"اگست",1
6749,"ViewTranslation","September [month]","",,"",6679,"ستمبر",1
6750,"ViewTranslation","October [month]","",,"",6679,"اكتوبر",1
6751,"ViewTranslation","November [month]","",,"",6679,"نومبر",1
6752,"ViewTranslation","December [month]","",,"",6679,"دسمبر",1
6753,"ViewTranslation","Jan [abbreviated month]","",,"",6679,"جنوري",1
6754,"ViewTranslation","Feb [abbreviated month]","",,"",6679,"فروري",1
6755,"ViewTranslation","Mar [abbreviated month]","",,"",6679,"مارچ",1
6756,"ViewTranslation","Apr [abbreviated month]","",,"",6679,"اپريل",1
6757,"ViewTranslation","May [abbreviated month]","",,"",6679,"مٓی",1
6758,"ViewTranslation","Jun [abbreviated month]","",,"",6679,"جون",1
6759,"ViewTranslation","Jul [abbreviated month]","",,"",6679,"جولاي",1
6760,"ViewTranslation","Aug [abbreviated month]","",,"",6679,"اگست",1
6761,"ViewTranslation","Sep [abbreviated month]","",,"",6679,"ستمبر",1
6762,"ViewTranslation","Oct [abbreviated month]","",,"",6679,"اكتوبر",1
6763,"ViewTranslation","Nov [abbreviated month]","",,"",6679,"نومبر",1
6764,"ViewTranslation","Dec [abbreviated month]","",,"",6679,"دسمبر",1
6765,"ViewTranslation","Sunday [weekday]","",,"",6719,"Якшанба",1
6766,"ViewTranslation","Monday [weekday]","",,"",6719,"Душанба",1
6767,"ViewTranslation","Tuesday [weekday]","",,"",6719,"Сешанба",1
6768,"ViewTranslation","Wednesday [weekday]","",,"",6719,"Чоршанба",1
6769,"ViewTranslation","Thursday [weekday]","",,"",6719,"Пайшанба",1
6770,"ViewTranslation","Friday [weekday]","",,"",6719,"Жума",1
6771,"ViewTranslation","Saturday [weekday]","",,"",6719,"Шанба",1
6772,"ViewTranslation","Sun [abbreviated weekday]","",,"",6719,"Якш",1
6773,"ViewTranslation","Mon [abbreviated weekday]","",,"",6719,"Душ",1
6774,"ViewTranslation","Tue [abbreviated weekday]","",,"",6719,"Сеш",1
6775,"ViewTranslation","Wed [abbreviated weekday]","",,"",6719,"Чор",1
6776,"ViewTranslation","Thu [abbreviated weekday]","",,"",6719,"Пай",1
6777,"ViewTranslation","Fri [abbreviated weekday]","",,"",6719,"Жум",1
6778,"ViewTranslation","Sat [abbreviated weekday]","",,"",6719,"Шан",1
6779,"ViewTranslation","January [month]","",,"",6719,"Январь",1
6780,"ViewTranslation","February [month]","",,"",6719,"Февраль",1
6781,"ViewTranslation","March [month]","",,"",6719,"Март",1
6782,"ViewTranslation","April [month]","",,"",6719,"Апрель",1
6783,"ViewTranslation","May [month]","",,"",6719,"Май",1
6784,"ViewTranslation","June [month]","",,"",6719,"Июнь",1
6785,"ViewTranslation","July [month]","",,"",6719,"Июль",1
6786,"ViewTranslation","August [month]","",,"",6719,"Август",1
6787,"ViewTranslation","September [month]","",,"",6719,"Сентябрь",1
6788,"ViewTranslation","October [month]","",,"",6719,"Октябрь",1
6789,"ViewTranslation","November [month]","",,"",6719,"Ноябрь",1
6790,"ViewTranslation","December [month]","",,"",6719,"Декабрь",1
6791,"ViewTranslation","Jan [abbreviated month]","",,"",6719,"Янв",1
6792,"ViewTranslation","Feb [abbreviated month]","",,"",6719,"Фев",1
6793,"ViewTranslation","Mar [abbreviated month]","",,"",6719,"Мар",1
6794,"ViewTranslation","Apr [abbreviated month]","",,"",6719,"Апр",1
6795,"ViewTranslation","May [abbreviated month]","",,"",6719,"Май",1
6796,"ViewTranslation","Jun [abbreviated month]","",,"",6719,"Июн",1
6797,"ViewTranslation","Jul [abbreviated month]","",,"",6719,"Июл",1
6798,"ViewTranslation","Aug [abbreviated month]","",,"",6719,"Авг",1
6799,"ViewTranslation","Sep [abbreviated month]","",,"",6719,"Сен",1
6800,"ViewTranslation","Oct [abbreviated month]","",,"",6719,"Окт",1
6801,"ViewTranslation","Nov [abbreviated month]","",,"",6719,"Ноя",1
6802,"ViewTranslation","Dec [abbreviated month]","",,"",6719,"Дек",1
6803,"ViewTranslation","Sunday [weekday]","",,"",6751,"Chủ nhật ",1
6804,"ViewTranslation","Monday [weekday]","",,"",6751,"Thứ hai ",1
6805,"ViewTranslation","Tuesday [weekday]","",,"",6751,"Thứ ba ",1
6806,"ViewTranslation","Wednesday [weekday]","",,"",6751,"Thứ tư ",1
6807,"ViewTranslation","Thursday [weekday]","",,"",6751,"Thứ năm ",1
6808,"ViewTranslation","Friday [weekday]","",,"",6751,"Thứ sáu ",1
6809,"ViewTranslation","Saturday [weekday]","",,"",6751,"Thứ bảy ",1
6810,"ViewTranslation","Sun [abbreviated weekday]","",,"",6751,"Cn ",1
6811,"ViewTranslation","Mon [abbreviated weekday]","",,"",6751,"Th 2 ",1
6812,"ViewTranslation","Tue [abbreviated weekday]","",,"",6751,"Th 3 ",1
6813,"ViewTranslation","Wed [abbreviated weekday]","",,"",6751,"Th 4 ",1
6814,"ViewTranslation","Thu [abbreviated weekday]","",,"",6751,"Th 5 ",1
6815,"ViewTranslation","Fri [abbreviated weekday]","",,"",6751,"Th 6 ",1
6816,"ViewTranslation","Sat [abbreviated weekday]","",,"",6751,"Th 7 ",1
6817,"ViewTranslation","January [month]","",,"",6751,"Tháng một",1
6818,"ViewTranslation","February [month]","",,"",6751,"Tháng hai",1
6819,"ViewTranslation","March [month]","",,"",6751,"Tháng ba",1
6820,"ViewTranslation","April [month]","",,"",6751,"Tháng tư",1
6821,"ViewTranslation","May [month]","",,"",6751,"Tháng năm",1
6822,"ViewTranslation","June [month]","",,"",6751,"Tháng sáu",1
6823,"ViewTranslation","July [month]","",,"",6751,"Tháng bảy",1
6824,"ViewTranslation","August [month]","",,"",6751,"Tháng tám",1
6825,"ViewTranslation","September [month]","",,"",6751,"Tháng chín",1
6826,"ViewTranslation","October [month]","",,"",6751,"Tháng mười",1
6827,"ViewTranslation","November [month]","",,"",6751,"Tháng mười một",1
6828,"ViewTranslation","December [month]","",,"",6751,"Tháng mười hai",1
6829,"ViewTranslation","Jan [abbreviated month]","",,"",6751,"Thg 1",1
6830,"ViewTranslation","Feb [abbreviated month]","",,"",6751,"Thg 2",1
6831,"ViewTranslation","Mar [abbreviated month]","",,"",6751,"Thg 3",1
6832,"ViewTranslation","Apr [abbreviated month]","",,"",6751,"Thg 4",1
6833,"ViewTranslation","May [abbreviated month]","",,"",6751,"Thg 5",1
6834,"ViewTranslation","Jun [abbreviated month]","",,"",6751,"Thg 6",1
6835,"ViewTranslation","Jul [abbreviated month]","",,"",6751,"Thg 7",1
6836,"ViewTranslation","Aug [abbreviated month]","",,"",6751,"Thg 8",1
6837,"ViewTranslation","Sep [abbreviated month]","",,"",6751,"Thg 9",1
6838,"ViewTranslation","Oct [abbreviated month]","",,"",6751,"Thg 10",1
6839,"ViewTranslation","Nov [abbreviated month]","",,"",6751,"Thg 11",1
6840,"ViewTranslation","Dec [abbreviated month]","",,"",6751,"Thg 12",1
6841,"ViewTranslation","Sunday [weekday]","",,"",6911,"Dîmegne",1
6842,"ViewTranslation","Monday [weekday]","",,"",6911,"Londi",1
6843,"ViewTranslation","Tuesday [weekday]","",,"",6911,"Mårdi",1
6844,"ViewTranslation","Wednesday [weekday]","",,"",6911,"Merkidi",1
6845,"ViewTranslation","Thursday [weekday]","",,"",6911,"Djudi",1
6846,"ViewTranslation","Friday [weekday]","",,"",6911,"Vinrdi",1
6847,"ViewTranslation","Saturday [weekday]","",,"",6911,"Semdi",1
6848,"ViewTranslation","Sun [abbreviated weekday]","",,"",6911,"Dîm",1
6849,"ViewTranslation","Mon [abbreviated weekday]","",,"",6911,"Lon",1
6850,"ViewTranslation","Tue [abbreviated weekday]","",,"",6911,"Mår",1
6851,"ViewTranslation","Wed [abbreviated weekday]","",,"",6911,"Mer",1
6852,"ViewTranslation","Thu [abbreviated weekday]","",,"",6911,"Dju",1
6853,"ViewTranslation","Fri [abbreviated weekday]","",,"",6911,"Vin",1
6854,"ViewTranslation","Sat [abbreviated weekday]","",,"",6911,"Sem",1
6855,"ViewTranslation","January [month]","",,"",6911,"Djanvî",1
6856,"ViewTranslation","February [month]","",,"",6911,"Fevrî",1
6857,"ViewTranslation","March [month]","",,"",6911,"Måss",1
6858,"ViewTranslation","April [month]","",,"",6911,"Avri",1
6859,"ViewTranslation","May [month]","",,"",6911,"May",1
6860,"ViewTranslation","June [month]","",,"",6911,"Djun",1
6861,"ViewTranslation","July [month]","",,"",6911,"Djulete",1
6862,"ViewTranslation","August [month]","",,"",6911,"Awousse",1
6863,"ViewTranslation","September [month]","",,"",6911,"Setimbe",1
6864,"ViewTranslation","October [month]","",,"",6911,"Octôbe",1
6865,"ViewTranslation","November [month]","",,"",6911,"Nôvimbe",1
6866,"ViewTranslation","December [month]","",,"",6911,"Decimbe",1
6867,"ViewTranslation","Jan [abbreviated month]","",,"",6911,"Dja",1
6868,"ViewTranslation","Feb [abbreviated month]","",,"",6911,"Fev",1
6869,"ViewTranslation","Mar [abbreviated month]","",,"",6911,"Mås",1
6870,"ViewTranslation","Apr [abbreviated month]","",,"",6911,"Avr",1
6871,"ViewTranslation","May [abbreviated month]","",,"",6911,"May",1
6872,"ViewTranslation","Jun [abbreviated month]","",,"",6911,"Djn",1
6873,"ViewTranslation","Jul [abbreviated month]","",,"",6911,"Djl",1
6874,"ViewTranslation","Aug [abbreviated month]","",,"",6911,"Awo",1
6875,"ViewTranslation","Sep [abbreviated month]","",,"",6911,"Set",1
6876,"ViewTranslation","Oct [abbreviated month]","",,"",6911,"Oct",1
6877,"ViewTranslation","Nov [abbreviated month]","",,"",6911,"Nôv",1
6878,"ViewTranslation","Dec [abbreviated month]","",,"",6911,"Dec",1
6879,"ViewTranslation","Sunday [weekday]","",,"",7078,"Cawe",1
6880,"ViewTranslation","Monday [weekday]","",,"",7078,"Mvulo",1
6881,"ViewTranslation","Tuesday [weekday]","",,"",7078,"Lwesibini",1
6882,"ViewTranslation","Wednesday [weekday]","",,"",7078,"Lwesithathu",1
6883,"ViewTranslation","Thursday [weekday]","",,"",7078,"Lwesine",1
6884,"ViewTranslation","Friday [weekday]","",,"",7078,"Lwesihlanu",1
6885,"ViewTranslation","Saturday [weekday]","",,"",7078,"Mgqibelo",1
6886,"ViewTranslation","Sun [abbreviated weekday]","",,"",7078,"Caw",1
6887,"ViewTranslation","Mon [abbreviated weekday]","",,"",7078,"Mvu",1
6888,"ViewTranslation","Tue [abbreviated weekday]","",,"",7078,"Bin",1
6889,"ViewTranslation","Wed [abbreviated weekday]","",,"",7078,"Tha",1
6890,"ViewTranslation","Thu [abbreviated weekday]","",,"",7078,"Sin",1
6891,"ViewTranslation","Fri [abbreviated weekday]","",,"",7078,"Hla",1
6892,"ViewTranslation","Sat [abbreviated weekday]","",,"",7078,"Mgq",1
6893,"ViewTranslation","January [month]","",,"",7078,"Janyuwari",1
6894,"ViewTranslation","February [month]","",,"",7078,"Februwari",1
6895,"ViewTranslation","March [month]","",,"",7078,"Matshi",1
6896,"ViewTranslation","April [month]","",,"",7078,"Epreli",1
6897,"ViewTranslation","May [month]","",,"",7078,"Meyi",1
6898,"ViewTranslation","June [month]","",,"",7078,"Juni",1
6899,"ViewTranslation","July [month]","",,"",7078,"Julayi",1
6900,"ViewTranslation","August [month]","",,"",7078,"Agasti",1
6901,"ViewTranslation","September [month]","",,"",7078,"Septemba",1
6902,"ViewTranslation","October [month]","",,"",7078,"Okthoba",1
6903,"ViewTranslation","November [month]","",,"",7078,"Novemba",1
6904,"ViewTranslation","December [month]","",,"",7078,"Disemba",1
6905,"ViewTranslation","Jan [abbreviated month]","",,"",7078,"Jan",1
6906,"ViewTranslation","Feb [abbreviated month]","",,"",7078,"Feb",1
6907,"ViewTranslation","Mar [abbreviated month]","",,"",7078,"Mat",1
6908,"ViewTranslation","Apr [abbreviated month]","",,"",7078,"Epr",1
6909,"ViewTranslation","May [abbreviated month]","",,"",7078,"Mey",1
6910,"ViewTranslation","Jun [abbreviated month]","",,"",7078,"Jun",1
6911,"ViewTranslation","Jul [abbreviated month]","",,"",7078,"Jul",1
6912,"ViewTranslation","Aug [abbreviated month]","",,"",7078,"Aga",1
6913,"ViewTranslation","Sep [abbreviated month]","",,"",7078,"Sep",1
6914,"ViewTranslation","Oct [abbreviated month]","",,"",7078,"Okt",1
6915,"ViewTranslation","Nov [abbreviated month]","",,"",7078,"Nov",1
6916,"ViewTranslation","Dec [abbreviated month]","",,"",7078,"Dis",1
6917,"ViewTranslation","Sunday [weekday]","",,"",7324,"זונטיק",1
6918,"ViewTranslation","Monday [weekday]","",,"",7324,"מאָנטיק",1
6919,"ViewTranslation","Tuesday [weekday]","",,"",7324,"דינסטיק",1
6920,"ViewTranslation","Wednesday [weekday]","",,"",7324,"מיטװאָך",1
6921,"ViewTranslation","Thursday [weekday]","",,"",7324,"דאָנערשטיק",1
6922,"ViewTranslation","Friday [weekday]","",,"",7324,"פֿרײַטיק",1
6923,"ViewTranslation","Saturday [weekday]","",,"",7324,"שבת",1
6924,"ViewTranslation","Sun [abbreviated weekday]","",,"",7324,"זונ'",1
6925,"ViewTranslation","Mon [abbreviated weekday]","",,"",7324,"מאָנ'",1
6926,"ViewTranslation","Tue [abbreviated weekday]","",,"",7324,"דינ'",1
6927,"ViewTranslation","Wed [abbreviated weekday]","",,"",7324,"מיט'",1
6928,"ViewTranslation","Thu [abbreviated weekday]","",,"",7324,"דאָנ'",1
6929,"ViewTranslation","Fri [abbreviated weekday]","",,"",7324,"פֿרײַ'",1
6930,"ViewTranslation","Sat [abbreviated weekday]","",,"",7324,"שבת",1
6931,"ViewTranslation","January [month]","",,"",7324,"יאַנואַר",1
6932,"ViewTranslation","February [month]","",,"",7324,"פֿעברואַר",1
6933,"ViewTranslation","March [month]","",,"",7324,"מאַרץ",1
6934,"ViewTranslation","April [month]","",,"",7324,"אַפּריל",1
6935,"ViewTranslation","May [month]","",,"",7324,"מײַ",1
6936,"ViewTranslation","June [month]","",,"",7324,"יוני",1
6937,"ViewTranslation","July [month]","",,"",7324,"יולי",1
6938,"ViewTranslation","August [month]","",,"",7324,"אױגסט",1
6939,"ViewTranslation","September [month]","",,"",7324,"סעפּטעמבער",1
6940,"ViewTranslation","October [month]","",,"",7324,"אָקטאָבער",1
6941,"ViewTranslation","November [month]","",,"",7324,"נaָװעמבער",1
6942,"ViewTranslation","December [month]","",,"",7324,"דצמבר",1
6943,"ViewTranslation","Jan [abbreviated month]","",,"",7324,"יאַנ'",1
6944,"ViewTranslation","Feb [abbreviated month]","",,"",7324,"פֿעב'",1
6945,"ViewTranslation","Mar [abbreviated month]","",,"",7324,"מאַר'",1
6946,"ViewTranslation","Apr [abbreviated month]","",,"",7324,"אַפּר'",1
6947,"ViewTranslation","May [abbreviated month]","",,"",7324,"מײַ",1
6948,"ViewTranslation","Jun [abbreviated month]","",,"",7324,"יונ'",1
6949,"ViewTranslation","Jul [abbreviated month]","",,"",7324,"יול'",1
6950,"ViewTranslation","Aug [abbreviated month]","",,"",7324,"אױג'",1
6951,"ViewTranslation","Sep [abbreviated month]","",,"",7324,"סעפּ'",1
6952,"ViewTranslation","Oct [abbreviated month]","",,"",7324,"אָקט'",1
6953,"ViewTranslation","Nov [abbreviated month]","",,"",7324,"נאָװ'",1
6954,"ViewTranslation","Dec [abbreviated month]","",,"",7324,"דעצ'",1
6955,"ViewTranslation","Sunday [weekday]","",,"",7484,"星期日",1
6956,"ViewTranslation","Monday [weekday]","",,"",7484,"星期一",1
6957,"ViewTranslation","Tuesday [weekday]","",,"",7484,"星期二",1
6958,"ViewTranslation","Wednesday [weekday]","",,"",7484,"星期三",1
6959,"ViewTranslation","Thursday [weekday]","",,"",7484,"星期四",1
6960,"ViewTranslation","Friday [weekday]","",,"",7484,"星期五",1
6961,"ViewTranslation","Saturday [weekday]","",,"",7484,"星期六",1
6962,"ViewTranslation","Sun [abbreviated weekday]","",,"",7484,"日",1
6963,"ViewTranslation","Mon [abbreviated weekday]","",,"",7484,"一",1
6964,"ViewTranslation","Tue [abbreviated weekday]","",,"",7484,"二",1
6965,"ViewTranslation","Wed [abbreviated weekday]","",,"",7484,"三",1
6966,"ViewTranslation","Thu [abbreviated weekday]","",,"",7484,"四",1
6967,"ViewTranslation","Fri [abbreviated weekday]","",,"",7484,"五",1
6968,"ViewTranslation","Sat [abbreviated weekday]","",,"",7484,"六",1
6969,"ViewTranslation","January [month]","",,"",7484,"一月",1
6970,"ViewTranslation","February [month]","",,"",7484,"二月",1
6971,"ViewTranslation","March [month]","",,"",7484,"三月",1
6972,"ViewTranslation","April [month]","",,"",7484,"四月",1
6973,"ViewTranslation","May [month]","",,"",7484,"五月",1
6974,"ViewTranslation","June [month]","",,"",7484,"六月",1
6975,"ViewTranslation","July [month]","",,"",7484,"七月",1
6976,"ViewTranslation","August [month]","",,"",7484,"八月",1
6977,"ViewTranslation","September [month]","",,"",7484,"九月",1
6978,"ViewTranslation","October [month]","",,"",7484,"十月",1
6979,"ViewTranslation","November [month]","",,"",7484,"十一月",1
6980,"ViewTranslation","December [month]","",,"",7484,"十二月",1
6981,"ViewTranslation","Jan [abbreviated month]","",,"",7484," 1月",1
6982,"ViewTranslation","Feb [abbreviated month]","",,"",7484," 2月",1
6983,"ViewTranslation","Mar [abbreviated month]","",,"",7484," 3月",1
6984,"ViewTranslation","Apr [abbreviated month]","",,"",7484," 4月",1
6985,"ViewTranslation","May [abbreviated month]","",,"",7484," 5月",1
6986,"ViewTranslation","Jun [abbreviated month]","",,"",7484," 6月",1
6987,"ViewTranslation","Jul [abbreviated month]","",,"",7484," 7月",1
6988,"ViewTranslation","Aug [abbreviated month]","",,"",7484," 8月",1
6989,"ViewTranslation","Sep [abbreviated month]","",,"",7484," 9月",1
6990,"ViewTranslation","Oct [abbreviated month]","",,"",7484,"10月",1
6991,"ViewTranslation","Nov [abbreviated month]","",,"",7484,"11月",1
6992,"ViewTranslation","Dec [abbreviated month]","",,"",7484,"12月",1
6993,"ViewTranslation","Sunday [weekday]","",,"",7594,"Sonto",1
6994,"ViewTranslation","Monday [weekday]","",,"",7594,"Msombuluko",1
6995,"ViewTranslation","Tuesday [weekday]","",,"",7594,"Lwesibili",1
6996,"ViewTranslation","Wednesday [weekday]","",,"",7594,"Lwesithathu",1
6997,"ViewTranslation","Thursday [weekday]","",,"",7594,"Lwesine",1
6998,"ViewTranslation","Friday [weekday]","",,"",7594,"Lwesihlanu",1
6999,"ViewTranslation","Saturday [weekday]","",,"",7594,"Mgqibelo",1
7000,"ViewTranslation","Sun [abbreviated weekday]","",,"",7594,"Son",1
7001,"ViewTranslation","Mon [abbreviated weekday]","",,"",7594,"Mso",1
7002,"ViewTranslation","Tue [abbreviated weekday]","",,"",7594,"Bil",1
7003,"ViewTranslation","Wed [abbreviated weekday]","",,"",7594,"Tha",1
7004,"ViewTranslation","Thu [abbreviated weekday]","",,"",7594,"Sin",1
7005,"ViewTranslation","Fri [abbreviated weekday]","",,"",7594,"Hla",1
7006,"ViewTranslation","Sat [abbreviated weekday]","",,"",7594,"Mgq",1
7007,"ViewTranslation","January [month]","",,"",7594,"Januwari",1
7008,"ViewTranslation","February [month]","",,"",7594,"Februwari",1
7009,"ViewTranslation","March [month]","",,"",7594,"Mashi",1
7010,"ViewTranslation","April [month]","",,"",7594,"Apreli",1
7011,"ViewTranslation","May [month]","",,"",7594,"Meyi",1
7012,"ViewTranslation","June [month]","",,"",7594,"Juni",1
7013,"ViewTranslation","July [month]","",,"",7594,"Julayi",1
7014,"ViewTranslation","August [month]","",,"",7594,"Agasti",1
7015,"ViewTranslation","September [month]","",,"",7594,"Septemba",1
7016,"ViewTranslation","October [month]","",,"",7594,"Okthoba",1
7017,"ViewTranslation","November [month]","",,"",7594,"Novemba",1
7018,"ViewTranslation","December [month]","",,"",7594,"Disemba",1
7019,"ViewTranslation","Jan [abbreviated month]","",,"",7594,"Jan",1
7020,"ViewTranslation","Feb [abbreviated month]","",,"",7594,"Feb",1
7021,"ViewTranslation","Mar [abbreviated month]","",,"",7594,"Mas",1
7022,"ViewTranslation","Apr [abbreviated month]","",,"",7594,"Apr",1
7023,"ViewTranslation","May [abbreviated month]","",,"",7594,"Mey",1
7024,"ViewTranslation","Jun [abbreviated month]","",,"",7594,"Jun",1
7025,"ViewTranslation","Jul [abbreviated month]","",,"",7594,"Jul",1
7026,"ViewTranslation","Aug [abbreviated month]","",,"",7594,"Aga",1
7027,"ViewTranslation","Sep [abbreviated month]","",,"",7594,"Sep",1
7028,"ViewTranslation","Oct [abbreviated month]","",,"",7594,"Okt",1
7029,"ViewTranslation","Nov [abbreviated month]","",,"",7594,"Nov",1
7030,"ViewTranslation","Dec [abbreviated month]","",,"",7594,"Dis",1
END_OF_DATA
  end  
end
