const { VUE_APP_BASE_API, VUE_APP_ENV, VUE_APP_MAPBOX_ACCESS_TOKEN, VUE_APP_MAPBOX_STYLE} = process.env

let constants = {}

constants.NOT_FOUND_404_TEXT = 'FAIL_TO_NOT_FOUND_SCREEN'
constants.LOCAL_COLOR = 'pink'
constants.STAGE_COLOR = 'orange'
constants.FLUX_COLOR = 'purple'
constants.UAT_COLOR = 'blue' //this is a light blue color
constants.PROD_COLOR = 'primary' //this is the dark blue prod color
constants.VUE_APP_ENV = VUE_APP_ENV
constants.VUE_APP_BASE_API = VUE_APP_BASE_API
constants.VUE_APP_API_PATH = '/api/v1'
constants.MAPBOX_ACCESS_TOKEN = VUE_APP_MAPBOX_ACCESS_TOKEN //I added this prop to all environments, so I am removing the fallback here cuz it was my personal token
constants.MAPBOX_STYLE = VUE_APP_MAPBOX_STYLE || 'mapbox://styles/mapbox/streets-v10'
constants.IS_MOBILE = window.innerWidth <= 768
constants.SCREEN_WIDTH = window.innerWidth
// constants.MAX_FILE_SIZE = 104857600 //100 mb
// constants.MAX_FILE_SIZE = 209715200 //200 mb
constants.MAX_FILE_SIZE = 1048576000 //1 gb
constants.WHITELISTED_FILE_EXTENSIONS = ['.png','.jpg','.jpeg','.gif','.tiff','.psd','.raw','.doc','.docx','.pdf','.xls','.xlsx','.xlsm','.dxf','.csv','.txt','.dwg','.xlsb']
//IMAGE_FILE_EXTENSIONS is used/formatted specifically for the attachment coversheet checks. make another one if you need one with . first
constants.IMAGE_FILE_EXTENSIONS = ['png','jpg','jpeg','gif','tiff','psd','raw']
constants.STANDARD_IMAGES_AND_DOCS = 'image/*, .doc, .docx, .pdf, .xls, .xlsx, .csv, .txt, .xlsm, .dxf, .dwg, .xlsb'
constants.STANDARD_IMAGES_ONLY = 'image/*'
constants.STANDARD_DOCS_ONLY = '.doc, .docx, .pdf, .xls, .xlsx, .csv, .txt, .xlsm, .xlsb, .dxf, .dwg'
constants.APP_FILE_TYPES = '.apk, .plist, .ipa'
constants.MAX_FILE_UPLOADS = 10
//TODO: rules likely need to be adjusted
constants.EMAIL_RULES = [
  v => !!v || "E-mail is required",
  v => /.+@.+[.].+/.test(v) || "E-mail must be valid" //br request to allow 1 char domain
  // v => /.+@.+.[.].+/.test(v) || "E-mail must be valid"
]

constants.POSTAL_CODE_RULES = [
  v => (!v || (v && (v.length === 0 || v.length === 5 || v.length === 10))) || 'Must be 5 or 10 characters',
  v => (!v || /^\d{5}(?:[-\s]\d{4})?$/.test(v)) || "Postal Code must be a valid format: ##### or #####-####"
]

constants.POSTAL_CODE_REQUIRED_RULES = [
  v => !!v || "Field is required",
  v => (!v || (v && (v.length === 0 || v.length === 5 || v.length === 10))) || 'Must be 5 or 10 characters',
  v => (!v || /^\d{5}(?:[-\s]\d{4})?$/.test(v)) || "Postal Code must be a valid format: ##### or #####-####"
]

constants.CITY_RULES = [
  v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
  v => (!v || /^[-.a-zA-Z0-9\s]+$/.test(v)) || "City must only contain alphanumeric, hyphen, period, or whitespace characters"
]

constants.ADDRESS_RULES = [
  v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
  v => (!v || /^[-#'.a-zA-Z0-9&\s]+$/.test(v)) || "Address must only contain alphanumeric, whitespace, or [-#'.&] characters"
]

constants.PASSWORD_RULES = [
  v => (!v || (v && (v.length >= 8))) || 'Must be at least 8 characters',
]

constants.PHONE_RULES = [
  v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
  v => /^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v) || "Please reformat the Phone field with a valid phone number"
]

constants.PHONE_REQUIRED_RULES = [
  v => !!v || "Field is required",
  v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
  v => /^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v) || "Please reformat the Phone field with a valid phone number"
]

constants.NAME_RULES = [
  v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
  v => (!v || (/^[-.&//a-zA-Z0-9\s]+$/.test(v) )) || "Cannot contain special characters"
]

constants.NAME_REQUIRED_RULES = [
  v => !!v || "Field is required",
  v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
  v => /^[-.&//a-zA-Z0-9\s]+$/.test(v) || "Cannot contain special characters"
]



constants.BASIC_REQUIRED_RULE = [
  v => (!!v || v === 0) || 'Field is required'
]
constants.BASIC_ARRAY_REQUIRED_RULE = [
  v => !!v || 'Field is required',
  v => (!v || (v && v.length !== 0)) || 'Field is required'
]
constants.USERNAME_RULES = [
  v => !!v || 'Username is required',
  v => !!v && v.length >= 3 || 'Must be at least 3 characters'
]
constants.COLOR_LIST = [
  '#e7211b', '#39b942', '#181e1e', '#eceb50',
  '#3ca5d6', '#9e4ed6', '#919393', '#e68f35',
  '#770909', '#1013c1', '#074f0a', '#42063e',
  '#402e11', '#98ffd5', '#ff7f9e', '#00fffc',
  '#3f3f3f', '#840046', '#3a0080', '#575f00'
]

constants.RESERVED_SQL_WORDS = ['a', 'abort', 'abs', 'absent', 'absolute', 'access','according', 'acos', 'action', 'ada', 'add','admin', 'after', 'aggregate', 'all', 'allocate','also', 'alter', 'always', 'analyse', 'analyze','and', 'any', 'are', 'array', 'array_agg','array_max_cardinality', 'as', 'asc', 'asensitive', 'asin','assertion', 'assignment', 'asymmetric', 'at', 'atan','atomic', 'attach', 'attribute', 'attributes', 'authorization','avg', 'backward', 'base64', 'before', 'begin','begin_frame', 'begin_partition', 'bernoulli', 'between', 'bigint','binary', 'bit', 'bit_length', 'blob', 'blocked','bom', 'boolean', 'both', 'breadth', 'by','c', 'cache', 'call', 'called', 'cardinality','cascade', 'cascaded', 'case', 'cast', 'catalog','catalog_name', 'ceil', 'ceiling', 'chain', 'chaining','char', 'character', 'characteristics', 'characters', 'character_length','character_set_catalog', 'character_set_name', 'character_set_schema', 'char_length', 'check','checkpoint', 'class', 'classifier', 'class_origin', 'clob','close', 'cluster', 'coalesce', 'cobol', 'collate','collation', 'collation_catalog', 'collation_name', 'collation_schema', 'collect','column', 'columns', 'column_name', 'command_function', 'command_function_code','comment', 'comments', 'commit', 'committed', 'compression','concurrently', 'condition', 'conditional', 'condition_number', 'configuration','conflict', 'connect', 'connection', 'connection_name', 'constraint','constraints', 'constraint_catalog', 'constraint_name', 'constraint_schema', 'constructor','contains', 'content', 'continue', 'control', 'conversion','convert', 'copy', 'corr', 'corresponding', 'cos','cosh', 'cost', 'count', 'covar_pop', 'covar_samp','create', 'cross', 'csv', 'cube', 'cume_dist','current', 'current_catalog', 'current_date', 'current_default_transform_group', 'current_path','current_role', 'current_row', 'current_schema', 'current_time', 'current_timestamp','current_transform_group_for_type', 'current_user', 'cursor', 'cursor_name', 'cycle','data', 'database', 'datalink', 'date', 'datetime_interval_code','datetime_interval_precision', 'day', 'db', 'deallocate', 'dec','decfloat', 'decimal', 'declare', 'default', 'defaults','deferrable', 'deferred', 'define', 'defined', 'definer','degree', 'delete', 'delimiter', 'delimiters', 'dense_rank','depends', 'depth', 'deref', 'derived', 'desc','describe', 'descriptor', 'detach', 'deterministic', 'diagnostics','dictionary', 'disable', 'discard', 'disconnect', 'dispatch','distinct', 'dlnewcopy', 'dlpreviouscopy', 'dlurlcomplete', 'dlurlcompleteonly','dlurlcompletewrite', 'dlurlpath', 'dlurlpathonly', 'dlurlpathwrite', 'dlurlscheme','dlurlserver', 'dlvalue', 'do', 'document', 'domain','double', 'drop', 'dynamic', 'dynamic_function', 'dynamic_function_code','each', 'element', 'else', 'elseif', 'elsif', 'empty', 'enable','encoding', 'encrypted', 'end', 'end-exec', 'end_frame','end_partition', 'enforced', 'enum', 'equals', 'error','escape', 'event', 'every', 'except', 'exception','exclude', 'excluding', 'exclusive', 'exec', 'execute','exists', 'exp', 'explain', 'expression', 'extension','external', 'extract', 'false', 'family', 'fetch','file', 'filter', 'final', 'finalize', 'finish','first', 'first_value', 'flag', 'float', 'floor','following', 'for', 'force', 'foreign', 'format','fortran', 'forward', 'found', 'frame_row', 'free','freeze', 'from', 'fs', 'fulfill', 'full','function', 'functions', 'fusion', 'g', 'general','generated', 'get', 'global', 'go', 'goto','grant', 'granted', 'greatest', 'group', 'grouping','groups', 'handler', 'having', 'header', 'hex','hierarchy', 'hold', 'hour', 'id', 'identity','if', 'ignore', 'ilike', 'immediate', 'immediately','immutable', 'implementation', 'implicit', 'import', 'in','include', 'including', 'increment', 'indent', 'index','indexes', 'indicator', 'inherit', 'inherits', 'initial','initially', 'inline', 'inner', 'inout', 'input','insensitive', 'insert', 'instance', 'instantiable', 'instead','int', 'integer', 'integrity', 'intersect', 'intersection','interval', 'into', 'invoker', 'is', 'isnull','isolation', 'join', 'json', 'json_array', 'json_arrayagg','json_exists', 'json_object', 'json_objectagg', 'json_query', 'json_table','json_table_primitive', 'json_value', 'k', 'keep', 'key','keys', 'key_member', 'key_type', 'label', 'lag','language', 'large', 'last', 'last_value', 'lateral','lead', 'leading', 'leakproof', 'least', 'left','length', 'level', 'library', 'like', 'like_regex','limit', 'link', 'listagg', 'listen', 'ln','load', 'local', 'localtime', 'localtimestamp', 'location','locator', 'lock', 'locked', 'log', 'log10','logged', 'lower', 'm', 'map', 'mapping','match', 'matched', 'matches', 'match_number', 'match_recognize','materialized', 'max', 'maxvalue', 'measures', 'member','merge', 'message_length', 'message_octet_length', 'message_text', 'method','min', 'minute', 'minvalue', 'mod', 'mode','modifies', 'module', 'month', 'more', 'move','multiset', 'mumps', 'name', 'names', 'namespace','national', 'natural', 'nchar', 'nclob', 'nested','nesting', 'new', 'next', 'nfc', 'nfd','nfkc', 'nfkd', 'nil', 'no', 'none','normalize', 'normalized', 'not', 'nothing', 'notify','notnull', 'nowait', 'nth_value', 'ntile', 'null','nullable', 'nullif', 'nulls', 'number', 'numeric','object', 'occurrences_regex', 'octets', 'octet_length', 'of','off', 'offset', 'oids', 'old', 'omit','on', 'one', 'only', 'open', 'operator','option', 'options', 'or', 'order', 'ordering','ordinality', 'others', 'out', 'outer', 'output','over', 'overflow', 'overlaps', 'overlay', 'overriding','owned', 'owner', 'p', 'pad', 'parallel','parameter', 'parameter_mode', 'parameter_name', 'parameter_ordinal_position', 'parameter_specific_catalog','parameter_specific_name', 'parameter_specific_schema', 'parser', 'partial', 'partition','pascal', 'pass', 'passing', 'passthrough', 'password','past', 'path', 'pattern', 'per', 'percent','percentile_cont', 'percentile_disc', 'percent_rank', 'period', 'permission','permute', 'placing', 'plan', 'plans', 'pli','policy', 'portion', 'position', 'position_regex', 'power','precedes', 'preceding', 'precision', 'prepare', 'prepared','preserve', 'primary', 'prior', 'private', 'privileges','procedural', 'procedure', 'procedures', 'program', 'prune','ptf', 'public', 'publication', 'quote', 'quotes','range', 'rank', 'read', 'reads', 'real','reassign', 'recheck', 'recovery', 'recursive', 'ref','references', 'referencing', 'refresh', 'regr_avgx', 'regr_avgy','regr_count', 'regr_intercept', 'regr_r2', 'regr_slope', 'regr_sxx','regr_sxy', 'regr_syy', 'reindex', 'relative', 'release','rename', 'repeatable', 'replace', 'replica', 'requiring','reset', 'respect', 'restart', 'restore', 'restrict','result', 'return', 'returned_cardinality', 'returned_length', 'returned_octet_length','returned_sqlstate', 'returning', 'returns', 'revoke', 'right','role', 'rollback', 'rollup', 'routine', 'routines','routine_catalog', 'routine_name', 'routine_schema', 'row', 'rows','row_count', 'row_number', 'rule', 'running', 'savepoint','scalar', 'scale', 'schema', 'schemas', 'schema_name','scope', 'scope_catalog', 'scope_name', 'scope_schema', 'scroll','search', 'second', 'section', 'security', 'seek','select', 'selective', 'self', 'sensitive', 'sequence','sequences', 'serializable', 'server', 'server_name', 'session','session_user', 'set', 'setof', 'sets', 'share','show', 'similar', 'simple', 'sin', 'sinh','size', 'skip', 'smallint', 'snapshot', 'some','source', 'space', 'specific', 'specifictype', 'specific_name','sql', 'sqlcode', 'sqlerror', 'sqlexception', 'sqlstate','sqlwarning', 'sqrt', 'stable', 'standalone', 'start','state', 'statement', 'static', 'statistics', 'stddev_pop','stddev_samp', 'stdin', 'stdout', 'storage', 'stored','strict', 'string', 'strip', 'structure', 'style','subclass_origin', 'submultiset', 'subscription', 'subset', 'substring','substring_regex', 'succeeds', 'sum', 'support', 'symmetric','sysid', 'system', 'system_time', 'system_user', 't','table', 'tables', 'tablesample', 'tablespace', 'table_name','tan', 'tanh', 'temp', 'template', 'temporary','text', 'then', 'through', 'ties', 'time','timestamp', 'timezone_hour', 'timezone_minute', 'to', 'token','top_level_count', 'trailing', 'transaction', 'transactions_committed', 'transactions_rolled_back','transaction_active', 'transform', 'transforms', 'translate', 'translate_regex','translation', 'treat', 'trigger', 'trigger_catalog', 'trigger_name','trigger_schema', 'trim', 'trim_array', 'true', 'truncate','trusted', 'type', 'types', 'uescape', 'unbounded','uncommitted', 'unconditional', 'under', 'unencrypted', 'union','unique', 'unknown', 'unlink', 'unlisten', 'unlogged','unmatched', 'unnamed', 'unnest', 'until', 'untyped','update', 'upper', 'uri', 'usage', 'user','user_defined_type_catalog', 'user_defined_type_code', 'user_defined_type_name', 'user_defined_type_schema', 'using','utf16', 'utf32', 'utf8', 'vacuum', 'valid','validate', 'validator', 'value', 'values', 'value_of','varbinary', 'varchar', 'variadic', 'varying', 'var_pop','var_samp', 'verbose', 'version', 'versioning', 'view','views', 'volatile', 'when', 'whenever', 'where','whitespace', 'width_bucket', 'window', 'with', 'within','without', 'work', 'wrapper', 'write', 'xml','xmlagg', 'xmlattributes', 'xmlbinary', 'xmlcast', 'xmlcomment','xmlconcat', 'xmldeclaration', 'xmldocument', 'xmlelement', 'xmlexists','xmlforest', 'xmliterate', 'xmlnamespaces', 'xmlparse', 'xmlpi','xmlquery', 'xmlroot', 'xmlschema', 'xmlserialize', 'xmltable','xmltext', 'xmlvalidate', 'year', 'yes', 'zone']

constants.SNACKBARS = {
  ERROR: {
    y: 'top',
    x: null,
    mode: '',
    timeout: 5000,
    text: '',
    color: 'error',
    fontClass: 'secondary--text'
  },
  SUCCESS: {
    y: 'top',
    x: null,
    mode: '',
    timeout: 5000,
    // timeout: 5000000,
    text: '',
    color: 'success lighten-1',
    fontClass: 'secondary--text'
  },
  WARNING: {
    y: 'top',
    x: null,
    mode: '',
    timeout: 5000,
    text: '',
    color: 'amber',
    fontClass: 'secondary--text'
  },
  INFO: {
    y: 'top',
    x: null,
    mode: '',
    timeout: 5000,
    text: '',
    color: 'primary',
    fontClass: 'secondary--text'
  }
}

constants.CSV_BLOB_TYPE = 'text/csv;charset=utf-8'

constants.OVERVIEW_FIELD_TYPES = {
  DEFAULT: 'default',
  DATE: 'date',
  STATUS: 'status',
  ADDRESS: 'address',
  PHONE: 'phone',
  OWNER: 'owner'
}

export default constants
