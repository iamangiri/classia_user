import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import '../../service/apiservice/can_service.dart';
import 'package:url_launcher/url_launcher.dart';


class CamsCreationScreen extends StatefulWidget {
  const CamsCreationScreen({Key? key}) : super(key: key);

  @override
  _CamsCreationScreenState createState() => _CamsCreationScreenState();
}

class _CamsCreationScreenState extends State<CamsCreationScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<GlobalKey<FormState>> _stepFormKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  int _currentStep = 0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _canNumber;
  bool _isCheckingCanStatus = true;

  // Form field controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _panController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthCityController = TextEditingController();
  final _resAddr1Controller = TextEditingController();
  final _resAddr2Controller = TextEditingController();
  final _resAddr3Controller = TextEditingController();
  final _resCityController = TextEditingController();
  final _resPincodeController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _nomineeNameController = TextEditingController();
  final _nomineeDobController = TextEditingController();
  final _nomineePiNoController = TextEditingController();
  final _nomineeMobileController = TextEditingController();
  final _nomineeEmailController = TextEditingController();
  final _nomineeAddr1Controller = TextEditingController();
  final _nomineeAddr2Controller = TextEditingController();
  final _nomineeAddr3Controller = TextEditingController();
  final _nomineeCityController = TextEditingController();
  final _nomineePincodeController = TextEditingController();
  final _netWorthController = TextEditingController();
  final _netDateController = TextEditingController();

  // Dropdown selections
  String? _birthCountry;
  String? _citizenship;
  String? _nationality;
  String? _taxResFlag;
  String? _resState;
  String? _resCountry;
  String? _grossIncome;
  String? _sourceOfWealth;
  String? _occupation;
  String? _pep;
  String? _resIsd;
  String? _resStd; // Changed to dropdown

  late CamService _camService;

  // Comprehensive country options
  final Map<String, String> countryOptions = {
    '004': 'Afghanistan',
    '008': 'Albania',
    '012': 'Algeria',
    '016': 'American Samoa',
    '020': 'Andorra',
    '024': 'Angola',
    '660': 'Anguilla',
    '010': 'Antarctica',
    '028': 'Antigua and Barbuda',
    '032': 'Argentina',
    '051': 'Armenia',
    '533': 'Aruba',
    '036': 'Australia',
    '040': 'Austria',
    '031': 'Azerbaijan',
    '044': 'Bahamas',
    '048': 'Bahrain',
    '050': 'Bangladesh',
    '052': 'Barbados',
    '112': 'Belarus',
    '056': 'Belgium',
    '084': 'Belize',
    '204': 'Benin',
    '060': 'Bermuda',
    '064': 'Bhutan',
    '068': 'Bolivia',
    '535': 'Bonaire, Sint Eustatius and Saba',
    '070': 'Bosnia and Herzegovina',
    '072': 'Botswana',
    '076': 'Brazil',
    '092': 'British Virgin Islands',
    '096': 'Brunei',
    '100': 'Bulgaria',
    '854': 'Burkina Faso',
    '108': 'Burundi',
    '116': 'Cambodia',
    '120': 'Cameroon',
    '124': 'Canada',
    '132': 'Cape Verde',
    '136': 'Cayman Islands',
    '140': 'Central African Republic',
    '148': 'Chad',
    '152': 'Chile',
    '156': 'China',
    '162': 'Christmas Island',
    '166': 'Cocos Islands',
    '170': 'Colombia',
    '174': 'Comoros',
    '178': 'Congo',
    '180': 'Congo (DRC)',
    '184': 'Cook Islands',
    '188': 'Costa Rica',
    '384': 'Côte d\'Ivoire',
    '191': 'Croatia',
    '192': 'Cuba',
    '531': 'Curaçao',
    '196': 'Cyprus',
    '203': 'Czech Republic',
    '208': 'Denmark',
    '262': 'Djibouti',
    '212': 'Dominica',
    '214': 'Dominican Republic',
    '218': 'Ecuador',
    '818': 'Egypt',
    '222': 'El Salvador',
    '226': 'Equatorial Guinea',
    '232': 'Eritrea',
    '233': 'Estonia',
    '748': 'Eswatini',
    '231': 'Ethiopia',
    '238': 'Falkland Islands',
    '234': 'Faroe Islands',
    '242': 'Fiji',
    '246': 'Finland',
    '250': 'France',
    '254': 'French Guiana',
    '258': 'French Polynesia',
    '266': 'Gabon',
    '270': 'Gambia',
    '268': 'Georgia',
    '276': 'Germany',
    '288': 'Ghana',
    '292': 'Gibraltar',
    '300': 'Greece',
    '304': 'Greenland',
    '308': 'Grenada',
    '312': 'Guadeloupe',
    '316': 'Guam',
    '320': 'Guatemala',
    '831': 'Guernsey',
    '324': 'Guinea',
    '624': 'Guinea-Bissau',
    '328': 'Guyana',
    '332': 'Haiti',
    '340': 'Honduras',
    '344': 'Hong Kong',
    '348': 'Hungary',
    '352': 'Iceland',
    '101': 'India',
    '360': 'Indonesia',
    '364': 'Iran',
    '368': 'Iraq',
    '372': 'Ireland',
    '833': 'Isle of Man',
    '376': 'Israel',
    '380': 'Italy',
    '388': 'Jamaica',
    '392': 'Japan',
    '832': 'Jersey',
    '400': 'Jordan',
    '398': 'Kazakhstan',
    '404': 'Kenya',
    '296': 'Kiribati',
    '383': 'Kosovo',
    '414': 'Kuwait',
    '417': 'Kyrgyzstan',
    '418': 'Laos',
    '428': 'Latvia',
    '422': 'Lebanon',
    '426': 'Lesotho',
    '430': 'Liberia',
    '434': 'Libya',
    '438': 'Liechtenstein',
    '440': 'Lithuania',
    '442': 'Luxembourg',
    '446': 'Macao',
    '450': 'Madagascar',
    '454': 'Malawi',
    '458': 'Malaysia',
    '462': 'Maldives',
    '466': 'Mali',
    '470': 'Malta',
    '584': 'Marshall Islands',
    '474': 'Martinique',
    '478': 'Mauritania',
    '480': 'Mauritius',
    '175': 'Mayotte',
    '484': 'Mexico',
    '583': 'Micronesia',
    '498': 'Moldova',
    '492': 'Monaco',
    '496': 'Mongolia',
    '499': 'Montenegro',
    '500': 'Montserrat',
    '504': 'Morocco',
    '508': 'Mozambique',
    '104': 'Myanmar',
    '516': 'Namibia',
    '520': 'Nauru',
    '524': 'Nepal',
    '528': 'Netherlands',
    '540': 'New Caledonia',
    '554': 'New Zealand',
    '558': 'Nicaragua',
    '562': 'Niger',
    '566': 'Nigeria',
    '570': 'Niue',
    '574': 'Norfolk Island',
    '408': 'North Korea',
    '807': 'North Macedonia',
    '580': 'Northern Mariana Islands',
    '578': 'Norway',
    '512': 'Oman',
    '586': 'Pakistan',
    '585': 'Palau',
    '275': 'Palestine',
    '591': 'Panama',
    '598': 'Papua New Guinea',
    '600': 'Paraguay',
    '604': 'Peru',
    '608': 'Philippines',
    '612': 'Pitcairn Islands',
    '616': 'Poland',
    '620': 'Portugal',
    '630': 'Puerto Rico',
    '634': 'Qatar',
    '638': 'Réunion',
    '642': 'Romania',
    '643': 'Russia',
    '646': 'Rwanda',
    '652': 'Saint Barthélemy',
    '654': 'Saint Helena',
    '659': 'Saint Kitts and Nevis',
    '662': 'Saint Lucia',
    '663': 'Saint Martin',
    '666': 'Saint Pierre and Miquelon',
    '670': 'Saint Vincent and the Grenadines',
    '882': 'Samoa',
    '674': 'San Marino',
    '678': 'São Tomé and Príncipe',
    '682': 'Saudi Arabia',
    '686': 'Senegal',
    '688': 'Serbia',
    '690': 'Seychelles',
    '694': 'Sierra Leone',
    '702': 'Singapore',
    '534': 'Sint Maarten',
    '703': 'Slovakia',
    '705': 'Slovenia',
    '090': 'Solomon Islands',
    '706': 'Somalia',
    '710': 'South Africa',
    '239': 'South Georgia',
    '410': 'South Korea',
    '728': 'South Sudan',
    '724': 'Spain',
    '144': 'Sri Lanka',
    '729': 'Sudan',
    '740': 'Suriname',
    '744': 'Svalbard and Jan Mayen',
    '752': 'Sweden',
    '756': 'Switzerland',
    '760': 'Syria',
    '158': 'Taiwan',
    '762': 'Tajikistan',
    '834': 'Tanzania',
    '764': 'Thailand',
    '626': 'Timor-Leste',
    '768': 'Togo',
    '772': 'Tokelau',
    '776': 'Tonga',
    '780': 'Trinidad and Tobago',
    '788': 'Tunisia',
    '792': 'Turkey',
    '795': 'Turkmenistan',
    '796': 'Turks and Caicos Islands',
    '798': 'Tuvalu',
    '800': 'Uganda',
    '804': 'Ukraine',
    '784': 'United Arab Emirates',
    '826': 'United Kingdom',
    '840': 'United States',
    '858': 'Uruguay',
    '850': 'US Virgin Islands',
    '860': 'Uzbekistan',
    '548': 'Vanuatu',
    '336': 'Vatican City',
    '862': 'Venezuela',
    '704': 'Vietnam',
    '876': 'Wallis and Futuna',
    '732': 'Western Sahara',
    '887': 'Yemen',
    '894': 'Zambia',
    '716': 'Zimbabwe',
  };

  final Map<String, String> stateOptions = {
    '001': 'Andhra Pradesh',
    '002': 'Arunachal Pradesh',
    '003': 'Assam',
    '004': 'Bihar',
    '005': 'Chhattisgarh',
    '006': 'Goa',
    '007': 'Gujarat',
    '008': 'Haryana',
    '009': 'Himachal Pradesh',
    '010': 'Jharkhand',
    '011': 'Karnataka',
    '012': 'Kerala',
    '013': 'Madhya Pradesh',
    '014': 'Maharashtra',
    '015': 'Manipur',
    '016': 'Meghalaya',
    '017': 'Mizoram',
    '018': 'Nagaland',
    '019': 'Odisha',
    '020': 'Punjab',
    '021': 'Rajasthan',
    '022': 'Sikkim',
    '023': 'Tamil Nadu',
    '024': 'Telangana',
    '025': 'Tripura',
    '026': 'Uttar Pradesh',
    '027': 'Uttarakhand',
    '028': 'West Bengal',
    '029': 'Andaman and Nicobar Islands',
    '030': 'Chandigarh',
    '031': 'Dadra and Nagar Haveli and Daman and Diu',
    '032': 'Delhi',
    '033': 'Jammu and Kashmir',
    '034': 'Ladakh',
    '035': 'Lakshadweep',
    '036': 'Puducherry',
  };

  final Map<String, String> grossIncomeOptions = {
    '01': 'Below 1 Lakh',
    '05': '1-5 Lakh',
    '10': '5-10 Lakh',
    '15': '10-25 Lakh',
    '20': 'Above 25 Lakh',
  };

  final Map<String, String> sourceOfWealthOptions = {
    '01': 'Salary',
    '02': 'Business',
    '03': 'Investments',
    '04': 'Inheritance',
    '05': 'Other',
  };

  final Map<String, String> occupationOptions = {
    '01': 'Professional',
    '02': 'Business',
    '03': 'Retired',
    '04': 'Self-Employed',
    '05': 'Homemaker',
    '06': 'Student',
    '07': 'Other',
  };

  final Map<String, String> pepOptions = {
    'N': 'No',
    'Y': 'Yes',
    'R': 'Related to PEP',
  };

  final Map<String, String> taxResFlagOptions = {
    'Y': 'Yes',
    'N': 'No',
  };

  final Map<String, String> isdOptions = {
    '91': '+91 (India)',
    '1': '+1 (US/Canada)',
    '7': '+7 (Russia)',
    '20': '+20 (Egypt)',
    '27': '+27 (South Africa)',
    '30': '+30 (Greece)',
    '31': '+31 (Netherlands)',
    '32': '+32 (Belgium)',
    '33': '+33 (France)',
    '34': '+34 (Spain)',
    '36': '+36 (Hungary)',
    '39': '+39 (Italy)',
    '40': '+40 (Romania)',
    '41': '+41 (Switzerland)',
    '43': '+43 (Austria)',
    '44': '+44 (UK)',
    '45': '+45 (Denmark)',
    '46': '+46 (Sweden)',
    '47': '+47 (Norway)',
    '48': '+48 (Poland)',
    '49': '+49 (Germany)',
    '52': '+52 (Mexico)',
    '53': '+53 (Cuba)',
    '54': '+54 (Argentina)',
    '55': '+55 (Brazil)',
    '60': '+60 (Malaysia)',
    '61': '+61 (Australia)',
    '62': '+62 (Indonesia)',
    '63': '+63 (Philippines)',
    '64': '+64 (New Zealand)',
    '65': '+65 (Singapore)',
    '66': '+66 (Thailand)',
    '81': '+81 (Japan)',
    '82': '+82 (South Korea)',
    '84': '+84 (Vietnam)',
    '86': '+86 (China)',
    '90': '+90 (Turkey)',
    '92': '+92 (Pakistan)',
    '93': '+93 (Afghanistan)',
    '94': '+94 (Sri Lanka)',
    '95': '+95 (Myanmar)',
    '98': '+98 (Iran)',
    '212': '+212 (Morocco)',
    '213': '+213 (Algeria)',
    '216': '+216 (Tunisia)',
    '966': '+966 (Saudi Arabia)',
    '971': '+971 (UAE)',
    '972': '+972 (Israel)',
    '973': '+973 (Bahrain)',
    '974': '+974 (Qatar)',
  };

  // STD Code dropdown options (Indian STD codes)
  final Map<String, String> stdOptions = {
    '011': '011 (Delhi)',
    '020': '020 (Pune)',
    '022': '022 (Mumbai)',
    '033': '033 (Kolkata)',
    '040': '040 (Hyderabad)',
    '044': '044 (Chennai)',
    '079': '079 (Ahmedabad)',
    '080': '080 (Bangalore)',
    '0120': '0120 (Noida)',
    '0124': '0124 (Gurgaon)',
    '0141': '0141 (Jaipur)',
    '0172': '0172 (Chandigarh)',
    '0181': '0181 (Jalandhar)',
    '0183': '0183 (Amritsar)',
    '0231': '0231 (Kolhapur)',
    '0241': '0241 (Aurangabad)',
    '0253': '0253 (Nashik)',
    '0265': '0265 (Vadodara)',
    '0278': '0278 (Bhuj)',
    '0281': '0281 (Surat)',
    '0326': '0326 (Bhubaneswar)',
    '0361': '0361 (Guwahati)',
    '0364': '0364 (Shillong)',
    '0381': '0381 (Agartala)',
    '0389': '0389 (Aizawl)',
    '0413': '0413 (Puducherry)',
    '0422': '0422 (Coimbatore)',
    '0452': '0452 (Madurai)',
    '0471': '0471 (Trivandrum)',
    '0481': '0481 (Kochi)',
    '0484': '0484 (Ernakulam)',
    '0512': '0512 (Kanpur)',
    '0522': '0522 (Lucknow)',
    '0542': '0542 (Varanasi)',
    '0612': '0612 (Patna)',
    '0651': '0651 (Ranchi)',
    '0661': '0661 (Cuttack)',
    '0674': '0674 (Bhubaneswar)',
    '0712': '0712 (Nagpur)',
    '0731': '0731 (Indore)',
    '0755': '0755 (Bhopal)',
    '0824': '0824 (Mangalore)',
    '0831': '0831 (Belgaum)',
    '0836': '0836 (Hubli)',
  };

  @override
  void initState() {
    super.initState();
    _camService = CamService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkCanStatus();
    _animationController.forward();
  }

  Future<void> _checkCanStatus() async {
    setState(() => _isCheckingCanStatus = true);
    try {
      final response = await _camService.getCanStatus();
      if (response['status'] == true && response['data']['can'] != null) {
        setState(() {
          _canNumber = response['data']['can'];
          _isCheckingCanStatus = false;
        });
      } else {
        setState(() => _isCheckingCanStatus = false);
      }
    } catch (e) {
      setState(() => _isCheckingCanStatus = false);
      print('Error checking CAN status: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _panController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthCityController.dispose();
    _resAddr1Controller.dispose();
    _resAddr2Controller.dispose();
    _resAddr3Controller.dispose();
    _resCityController.dispose();
    _resPincodeController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _nomineeNameController.dispose();
    _nomineeDobController.dispose();
    _nomineePiNoController.dispose();
    _nomineeMobileController.dispose();
    _nomineeEmailController.dispose();
    _nomineeAddr1Controller.dispose();
    _nomineeAddr2Controller.dispose();
    _nomineeAddr3Controller.dispose();
    _nomineeCityController.dispose();
    _nomineePincodeController.dispose();
    _netWorthController.dispose();
    _netDateController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _stepFormKeys[0].currentState?.validate() ?? false &&
            _birthCountry != null &&
            _citizenship != null &&
            _nationality != null &&
            _taxResFlag != null &&
            _resIsd != null;
      case 1:
        return _stepFormKeys[1].currentState?.validate() ?? false &&
            _resState != null &&
            _resCountry != null &&
            _resStd != null;
      case 2:
        return _stepFormKeys[2].currentState?.validate() ?? false;
      case 3:
        return _stepFormKeys[3].currentState?.validate() ?? false &&
            _grossIncome != null &&
            _sourceOfWealth != null &&
            _occupation != null &&
            _pep != null;
      case 4:
        return _stepFormKeys[4].currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 4) {
        setState(() {
          _currentStep += 1;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        _submitForm();
      }
    } else {
      _showValidationError();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(),
            Expanded(
              child: Text(
                'Please fill all required fields correctly',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    try {
      final payload = {
        "holdingType": "SI",
        "investorCategory": "I",
        "taxStatus": "RI",
        "holders": [
          {
            "type": "PR",
            "name": _nameController.text,
            "dob": _dobController.text,
            "panExemptFlag": "N",
            "panPekrnNo": _panController.text,
            "contactDetail": {
              "resIsd": _resIsd ?? "",
              "resStd": _resStd ?? "",
              "resPhoneNo": "",
              "mobIsdCode": _resIsd ?? "",
              "priMobNo": _phoneController.text,
              "altMobNo": "",
              "offIsd": "",
              "offStd": "",
              "offPhoneNo": "",
              "priEmail": _emailController.text,
              "altEmail": ""
            },
            "kycData": {
              "kycStatus": "KRG",
              "sourceKra": "CAMS",
              "resAddrDetail": {
                "addr1": _resAddr1Controller.text,
                "addr2": _resAddr2Controller.text,
                "addr3": _resAddr3Controller.text,
                "city": _resCityController.text,
                "pincode": _resPincodeController.text,
                "state": _resState,
                "country": _resCountry,
              },
              "perAddrDetail": {
                "addr1": _resAddr1Controller.text,
                "addr2": _resAddr2Controller.text,
                "addr3": _resAddr3Controller.text,
                "city": _resCityController.text,
                "pincode": _resPincodeController.text,
                "state": _resState,
                "country": _resCountry,
              },
            },
            "otherDetail": {
              "grossIncome": _grossIncome,
              "netWorth": _netWorthController.text,
              "netDate": _netDateController.text,
              "sourceOfWealth": _sourceOfWealth,
              "kraAddrType": "1",
              "occupation": _occupation,
              "pep": _pep,
            },
            "fatcaDetail": {
              "birthCity": _birthCityController.text,
              "birthCountry": _birthCountry,
              "citizenship": _citizenship,
              "nationality": _nationality,
              "taxResFlag": _taxResFlag,
              "taxRecords": [{"seqNum": "1"}],
            },
          },
        ],
        "bankDetails": [
          {
            "seqNum": 1,
            "defaultAccFlag": "Y",
            "accountNo": _bankAccountController.text,
            "accountType": "SB",
            "bankId": "0065",
            "micrCode": "400065002",
            "ifscCode": _ifscController.text,
            "proof": "14",
          },
        ],
        "nomineeDetails": {
          "nomDeclLvl": "C",
          "nominOptFlag": "Y",
          "nomFolioSoa": "Y",
          "nomineeesRecords": [
            {
              "seqNum": 1,
              "nomineeName": _nomineeNameController.text,
              "relation": "MFU01",
              "percentage": "100",
              "dob": _nomineeDobController.text,
              "nomPiType": "DL",
              "nomPiNo": _nomineePiNoController.text,
              "nomMobile": _nomineeMobileController.text,
              "nomEmail": _nomineeEmailController.text,
              "nomAddr1": _nomineeAddr1Controller.text,
              "nomAddr2": _nomineeAddr2Controller.text,
              "nomAddr3": _nomineeAddr3Controller.text,
              "nomPincode": _nomineePincodeController.text,
              "nomCity": _nomineeCityController.text,
              "nomCountry": "101",
            },
          ],
        },
        "arnDetails": {
          "arnNo": "ARN-325802",
          "euinCode": "E618071",
        },
        "consentDetails": [
          {"dataSet": "PD", "enabledConsent": "Y"},
          {"dataSet": "CD", "enabledConsent": "Y"},
          {"dataSet": "MF", "enabledConsent": "N"},
          {"dataSet": "HD", "enabledConsent": "N"},
        ],
        "dpDetails": {
          "nsdlDpId": "IN123456",
          "nsdlClientId": "12345678",
          "nsdlProofId": "34",
          "nsdlVerFlag": "Y",
        },
      };

      final response = await _camService.createCams(payload);
      if (!mounted) return;

      if (response['status'] == true) {
        final xmlData = response['data'];
        final nomVerLinkH1 = _extractNomVerLinkH1(xmlData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'CAMS account created successfully!',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );

        if (nomVerLinkH1 != null && nomVerLinkH1.isNotEmpty) {
          final Uri url = Uri.parse(nomVerLinkH1);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not launch verification link'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }

        await _checkCanStatus();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Error: ${e.toString()}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String? _extractNomVerLinkH1(String xmlData) {
    final RegExp linkRegex = RegExp(r'<NOM_VER_LINK_H1>(.*?)</NOM_VER_LINK_H1>');
    final match = linkRegex.firstMatch(xmlData);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Create CAMS Account',
      ),
      body: _isCheckingCanStatus
          ? Center(child: CircularProgressIndicator())
          : _canNumber != null
          ? _buildCanDisplay()
          : _buildForm(),
    );
  }

  Widget _buildCanDisplay() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'Your CAN Number',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _canNumber!,
                style: TextStyle(
                  color: AppColors.buttonBackground,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  setState(() => _canNumber = null);
                  _animationController.forward();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: AppColors.buttonText,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                ),
                child: Text(
                  'Create New CAN',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  height: 4.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.r),
                    color: index <= _currentStep
                        ? AppColors.buttonBackground
                        : AppColors.disabledText.withOpacity(0.3),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: _buildCurrentStepContent(),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 10.w),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _previousStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.buttonBackground,
                        elevation: 0,
                        side: BorderSide(
                          color: AppColors.buttonBackground,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: _currentStep > 0 ? 1 : 2,
                child: Container(
                  margin: EdgeInsets.only(left: _currentStep > 0 ? 10.w : 0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      foregroundColor: AppColors.buttonText,
                      elevation: 2,
                      shadowColor: AppColors.buttonBackground.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
                        strokeWidth: 2,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 4 ? 'Submit' : 'Next',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_currentStep < 4) ...[
                          SizedBox(width: 4.w),
                          Icon(Icons.arrow_forward_ios, size: 16.sp),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    final stepTitles = [
      'Personal Details',
      'Address Information',
      'Bank Details',
      'Financial Information',
      'Nominee Details',
    ];

    final stepIcons = [
      Icons.person_outline,
      Icons.location_on_outlined,
      Icons.account_balance_outlined,
      Icons.monetization_on_outlined,
      Icons.people_outline,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.buttonBackground.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    stepIcons[_currentStep],
                    color: AppColors.buttonBackground,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of 5',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        stepTitles[_currentStep],
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Form(
              key: _stepFormKeys[_currentStep],
              child: _getStepContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDetails();
      case 1:
        return _buildAddressDetails();
      case 2:
        return _buildBankDetails();
      case 3:
        return _buildOtherDetails();
      case 4:
        return _buildNomineeDetails();
      default:
        return Container();
    }
  }


  Widget _buildPersonalDetails() {
    return Column(
      children: [
        _buildTextField(_nameController, 'Full Name', 'Enter your full name', Icons.person_outline,
            validator: (v) => v!.isEmpty ? 'Required' : null),
        SizedBox(height: 16.h),
        _buildTextField(_dobController, 'Date of Birth', 'YYYY-MM-DD', Icons.calendar_today_outlined,
            validator: _validateDateOfBirth),
        SizedBox(height: 16.h),
        _buildTextField(_panController, 'PAN Number', 'e.g. ABCDE1234F', Icons.credit_card_outlined,
            validator: (v) => v!.isEmpty
                ? 'Required'
                : RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v)
                ? null
                : 'Invalid PAN'),
        SizedBox(height: 16.h),
        _buildTextField(_phoneController, 'Phone Number', '10-digit mobile', Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) => RegExp(r'^\d{10}$').hasMatch(v!) ? null : 'Invalid mobile'),
        SizedBox(height: 16.h),
        _buildDropdownField('Residence ISD Code', _resIsd, isdOptions, Icons.phone_outlined,
                (v) => setState(() => _resIsd = v)),
        SizedBox(height: 16.h),
        _buildTextField(_emailController, 'Email', 'your@email.com', Icons.email_outlined,
            validator: (v) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)
                ? null
                : 'Invalid email'),
        SizedBox(height: 16.h),
        _buildTextField(_birthCityController, 'Birth City', 'City of birth', Icons.location_city_outlined,
            validator: (v) => v!.isEmpty ? 'Required' : null),
        SizedBox(height: 16.h),
        _buildDropdownField('Birth Country', _birthCountry, countryOptions, Icons.flag_outlined,
                (v) => setState(() => _birthCountry = v)),
        SizedBox(height: 16.h),
        _buildDropdownField('Citizenship', _citizenship, countryOptions, Icons.password_outlined,
                (v) => setState(() => _citizenship = v)),
        SizedBox(height: 16.h),
        _buildDropdownField('Nationality', _nationality, countryOptions, Icons.public_outlined,
                (v) => setState(() => _nationality = v)),
        SizedBox(height: 16.h),
        _buildDropdownField('Tax Residency (Outside India?)', _taxResFlag, taxResFlagOptions,
            Icons.receipt_long_outlined, (v) => setState(() => _taxResFlag = v)),
      ],
    );
  }

  Widget _buildAddressDetails() {
    return Column(
      children: [
        _buildTextField(_resAddr1Controller, 'Address Line 1', 'Flat/House no., Building', Icons.home_outlined,
            validator: (v) => v!.isEmpty ? 'Required' : null),
        SizedBox(height: 16.h),
        _buildTextField(_resAddr2Controller, 'Address Line 2', 'Street/Locality (optional)', Icons.home_work_outlined),
        SizedBox(height: 16.h),
        _buildTextField(_resAddr3Controller, 'Address Line 3', 'Landmark (optional)', Icons.home_work_outlined),
        SizedBox(height: 16.h),
        _buildTextField(_resCityController, 'City', 'Enter city', Icons.location_city_outlined,
            validator: (v) => v!.isEmpty ? 'Required' : null),
        SizedBox(height: 16.h),
        _buildTextField(_resPincodeController, 'Pincode', '6-digit pincode', Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            validator: (v) => RegExp(r'^\d{6}$').hasMatch(v!) ? null : 'Invalid pincode'),
        SizedBox(height: 16.h),
        _buildDropdownField('State', _resState, stateOptions, Icons.map_outlined,
                (v) => setState(() => _resState = v)),
        SizedBox(height: 16.h),
        _buildDropdownField('Country', _resCountry, countryOptions, Icons.flag_outlined,
                (v) => setState(() => _resCountry = v)),
        SizedBox(height: 16.h),
        _buildDropdownField('STD Code', _resStd, stdOptions, Icons.dialpad_outlined,
                (v) => setState(() => _resStd = v)),
      ],
    );
  }

  Widget _buildBankDetails() {
    return Column(
      children: [
        _buildTextField(_bankAccountController, 'Bank Account Number', '9-18 digits', Icons.account_balance_outlined,
            keyboardType: TextInputType.number,
            validator: (v) => RegExp(r'^\d{9,18}$').hasMatch(v!) ? null : 'Invalid account number'),
        SizedBox(height: 16.h),
        _buildTextField(_ifscController, 'IFSC Code', 'e.g. SBIN0001234', Icons.account_balance_wallet_outlined,
            validator: (v) {
              if (v!.isEmpty) return 'Required';
              return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v.toUpperCase())
                  ? null
                  : 'Invalid IFSC';
            }),
      ],
    );
  }

  Widget _buildOtherDetails() {
    return Column(
      children: [
        _buildDropdownField('Gross Annual Income', _grossIncome, grossIncomeOptions, Icons.monetization_on_outlined,
                (v) => setState(() => _grossIncome = v)),
        SizedBox(height: 16.h),
        _buildTextField(_netWorthController, 'Net Worth (₹)', 'Amount in INR', Icons.account_balance_wallet_outlined,
            keyboardType: TextInputType.number,
            validator: (v) => double.tryParse(v!) != null ? null : 'Invalid amount'),
        SizedBox(height: 16.h),
        _buildTextField(_netDateController, 'Net Worth As Of', 'YYYY-MM-DD', Icons.calendar_today_outlined,
            validator: _validatePastDate),
        SizedBox(height: 16.h),
        _buildDropdownField('Source of Wealth', _sourceOfWealth, sourceOfWealthOptions, Icons.source_outlined,
                (v) => setState(() => _sourceOfWealth = v)),
        SizedBox(height: 16.h),
        _buildDropdownField('Occupation', _occupation, occupationOptions, Icons.work_outline,
                (v) => setState(() => _occupation = v)),
        SizedBox(height: 16.h),
        _buildDropdownField('Politically Exposed Person (PEP)', _pep, pepOptions, Icons.verified_user_outlined,
                (v) => setState(() => _pep = v)),
      ],
    );
  }

  Widget _buildNomineeDetails() {
    return Column(
      children: [
        _buildTextField(_nomineeNameController, 'Nominee Name', 'Full name', Icons.person_add_outlined,
            validator: (v) => v!.isEmpty ? 'Required' : null),
        SizedBox(height: 16.h),
        _buildTextField(_nomineeDobController, 'Nominee DOB', 'YYYY-MM-DD', Icons.calendar_today_outlined,
            validator: _validatePastDate),
        SizedBox(height: 16.h),
        _buildTextField(_nomineePiNoController, 'Nominee PAN/ID', 'PAN or ID proof no.', Icons.credit_card_outlined,
            validator: (v) => v!.isEmpty ? 'Required' : null),
        SizedBox(height: 16.h),
        _buildTextField(_nomineeMobileController, 'Nominee Mobile', '10 digits', Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) => RegExp(r'^\d{10}$').hasMatch(v!) ? null : 'Invalid mobile'),
        SizedBox(height: 16.h),
        _buildTextField(_nomineeEmailController, 'Nominee Email', 'email@domain.com', Icons.email_outlined,
            validator: (v) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)
                ? null
                : 'Invalid email'),
        SizedBox(height: 16.h),
        _buildTextField(_nomineeAddr1Controller, 'Address Line 1', 'Flat/House', Icons.home_outlined,
            validator: (v) => v!.isEmpty ? 'Required' : null),
        SizedBox(height: 16.h),
        _buildTextField(_nomineeAddr2Controller, 'Address Line 2', '(optional)', Icons.home_work_outlined),
        SizedBox(height: 16.h),
        _buildTextField(_nomineeAddr3Controller, 'Address Line 3', '(optional)', Icons.home_work_outlined),
        SizedBox(height: 16.h),
        _buildTextField(_nomineeCityController, 'City', 'City name', Icons.location_city_outlined,
            validator: (v) => v!.isEmpty ? 'Required' : null),
        SizedBox(height: 16.h),
        _buildTextField(_nomineePincodeController, 'Pincode', '6 digits', Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            validator: (v) => RegExp(r'^\d{6}$').hasMatch(v!) ? null : 'Invalid pincode'),
      ],
    );
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return 'Use YYYY-MM-DD';

    try {
      final parts = value.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      if (date.isAfter(DateTime.now())) return 'Cannot be future date';
      if (DateTime.now().year - date.year < 18) return 'Must be 18+ years old';
      return null;
    } catch (e) {
      return 'Invalid date';
    }
  }

  String? _validatePastDate(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return 'Use YYYY-MM-DD';
    try {
      final date = DateTime.tryParse(value);
      if (date == null || date.isAfter(DateTime.now())) return 'Cannot be future date';
      return null;
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.secondaryText, size: 20.sp),
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.3), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.3), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.buttonBackground, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      String? value,
      Map<String, String> items,
      IconData icon,
      void Function(String?) onChanged,
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryText, size: 20.sp),
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.3), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.3), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.buttonBackground, width: 2),
          ),
        ),
        items: items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
        dropdownColor: AppColors.cardBackground,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryText),
        isExpanded: true,
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }
}