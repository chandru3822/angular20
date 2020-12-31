package com.albatross.api.chase_bank;

import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.base.CharMatcher;
import com.ibm.icu.text.Transliterator;
import lombok.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.function.Predicate;
import java.util.regex.Pattern;

import static com.google.common.base.Preconditions.checkArgument;
import static org.apache.commons.lang3.StringUtils.*;

@AllArgsConstructor
@Builder
@Getter
@JsonPropertyOrder({"courierCode",
                    "formCode",
                    "paymentDate",
                    "paymentAmount",
                    "acctNumber",
                    "checkNumber",
                    "firstPayeeName",
                    "secondPayeeName",
                    "vendorNumber",
                    "payeeAddressLine1",
                    "payeeAddressLine2",
                    "payeePhone",
                    "payeeAddressLine3",
                    "payeeAddressLine4",
                    "payeeCity",
                    "payeeState",
                    "payeePostalCode",
                    "payeeCountry",
                    "invoiceNumber",
                    "description",
                    "invoiceDate",
                    "netAmount",
                    "grossAmount",
                    "discountAmount"})
public class Ap6DelimitedSingleLineRecord {
    private static final Pattern ALPHANUMERIC_HYPHEN_REGEX = Pattern.compile("[-a-zA-Z0-9]+");

    public static String exportAsCsvString(List<Ap6DelimitedSingleLineRecord> records)
            throws IOException {
        CsvMapper csvMapper = new CsvMapper();

        // tell Jackson to use toString() to get each object's value
        SimpleModule module = new SimpleModule();
        module.addSerializer(ToStringSerializable.class, ToStringSerializer.instance);
        csvMapper.registerModule(module);

        // define CSV headers
        CsvSchema schema = csvMapper.schemaFor(com.albatross.api.chase_bank.Ap6DelimitedSingleLineRecord.class);

        // write to CSV
        return csvMapper.writer(schema)
                        .writeValueAsString(records)
                        .trim();  // Jackson appends final \n, which is valid CSV but breaks JP Morgan :(
    }


    private static final ZoneId AMERICAN_FORK_TZ = ZoneId.of("America/Denver");
    private static final DateTimeFormatter f = DateTimeFormatter.ofPattern("MM/dd/yyyy");

    private static boolean lessThan(BigDecimal d, Double val) {
        return d.compareTo(BigDecimal.valueOf(val)) < 0;
    }


    @NonNull
    private Amount paymentAmount;
    @NonNull
    private Amount netAmount;
    @NonNull
    @Builder.Default private Amount grossAmount = Amount.ZERO;
    @NonNull
    @Builder.Default private Amount discountAmount = Amount.ZERO;
    @NonNull
    private InvoiceDate invoiceDate;
    @NonNull
    private Description description;
    @NonNull
    private CourierCode courierCode;
    @NonNull
    private FormCode formCode;
    @NonNull
    private PaymentDate paymentDate;
    @NonNull
    private AccountNumber acctNumber;
    @NonNull
    private CheckNumber checkNumber;
    @NonNull
    private InvoiceNumber invoiceNumber;
    @NonNull
    private Name firstPayeeName;
                              private Name secondPayeeName;
    @NonNull                  private VendorNumber vendorNumber;
                              private Phone payeePhone;
    @NonNull
    private AddressLine payeeAddressLine1;
                              private AddressLine payeeAddressLine2;
                              private AddressLine payeeAddressLine3;
                              private AddressLine payeeAddressLine4;
    @NonNull
    private City payeeCity;
    @NonNull
    private State payeeState;
    @NonNull
    private PostalCode payeePostalCode;
    @NonNull
    private final String payeeCountry = "USA";


    ///////////////////////////////////////////////////////////////////////////
    // having this many classes is ridiculous but is the cleanest way I know to
    // basically do dependent types on these fields
    ///////////////////////////////////////////////////////////////////////////
    private static final Transliterator transliterator = Transliterator.getInstance("Any-Latin; Latin-ASCII");

    // tagging interface to tell Jackson to use ToStringSerializer on these classes
    private interface ToStringSerializable {}

    public static class CourierCode implements ToStringSerializable {
        private final String courierCode;

        public CourierCode(String s) {
            checkArgument(isAlphanumeric(s), "courier code must only contain alphanumeric chars");
            checkArgument(s.length() >= 4, "courier code must be at least four chars");
            checkArgument(s.length() <= 8, "courier code must be no longer than eight chars");
            this.courierCode = s;
        }

        public String toString() {
            return courierCode;
        }
    }

    public static class FormCode implements ToStringSerializable {
        private final String formCode;

        public FormCode(String s) {
            checkArgument(isAlphanumeric(s), "form code must only contain alphanumeric chars");
            checkArgument(s.length() <= 8, "form code must be no longer than eight chars");
            this.formCode = s;
        }

        public String toString() {
            return formCode;
        }
    }

    public static class PaymentDate implements ToStringSerializable {
        @Getter
        private final LocalDate date;

        public PaymentDate(LocalDate d) {
            final LocalDate today = LocalDate.now();

            checkArgument(d.isEqual(today) || d.isAfter(today),
                    String.format("payment date must be on or after today (%s)", LocalDate.now()));
            this.date = d;
        }

        public PaymentDate(Date d) {
            this(d.toInstant().atZone(AMERICAN_FORK_TZ).toLocalDate());
        }

        public String toString() {
            return f.format(date);
        }
    }

    public static class Amount implements ToStringSerializable {
        public static final Amount ZERO = new Amount(BigDecimal.ZERO);
        @Getter
        private final BigDecimal amount;

        public Amount(BigDecimal d) {
            checkArgument(0 <= d.scale() && d.scale() <= 2, "payment amount must have between zero and two cents digits");
            checkArgument(lessThan(d, 1e8), "payment value must be less than $100,000,000");
            this.amount = d;
        }

        public Amount(Double d) {
            this(BigDecimal.valueOf(d));
        }

        public String toString() {
            return amount.toPlainString();
        }
    }

    public static class AccountNumber implements ToStringSerializable {
        private final String acctNum;

        public AccountNumber(Object acctNum) {
            this(acctNum.toString());
        }

        public AccountNumber(String acctNum) {
            checkArgument(isNumeric(acctNum), "account number must only be numbers");
            checkArgument(acctNum.length() <= 17, "account number must be no more than 17 digits");
            this.acctNum = acctNum;
        }

        public String toString() {
            return acctNum;
        }
    }

    public static class CheckNumber implements ToStringSerializable {
        private final String checkNum;

        public CheckNumber(Integer checkNum) {
            this(checkNum.toString());
        }

        public CheckNumber(String checkNum) {
            checkArgument(isNumeric(checkNum), "check number must only be numbers");
            checkArgument(checkNum.length() <= 10, "check number must be no more than 10 digits");
            this.checkNum = checkNum;
        }

        public String toString() {
            return checkNum;
        }
    }

    public static class InvoiceNumber implements ToStringSerializable {
      private final String invoiceNum;

      public InvoiceNumber(Integer invoiceNum) {
        this(invoiceNum.toString());
      }

      public InvoiceNumber(String invoiceNum) {
        checkArgument(isNumeric(invoiceNum), "check number must only be numbers");
        checkArgument(invoiceNum.length() <= 30, "check number must be no more than 30 digits");
        this.invoiceNum = invoiceNum;
      }

      public String toString() {
        return invoiceNum;
      }
    }

    public static class Name implements ToStringSerializable {
        private static final Predicate<String> validChars = CharMatcher.javaLetterOrDigit()
                .or(CharMatcher.forPredicate(Character::isSpaceChar))
                .or(CharMatcher.anyOf("-.&/'"))
                .precomputed()::matchesAllOf;

        private final String name;

        public Name(String _s) {
            String s = transliterator.transliterate(_s);
            checkArgument(validChars.test(s), "name must only contain letters, numbers, whitespace, or [-.&/'] chars");
            this.name = left(s, 35); // string must be no longer than 35 chars
        }

        public String toString() {
            return name;
        }
    }

    public static class VendorNumber implements ToStringSerializable {
      private final String vendorNumber;

      public VendorNumber(Integer i) {
        this(String.valueOf(i));
      }

      public VendorNumber(String s) {
        checkArgument(isAlphanumeric(s), "vendor number must only contain alphanumeric chars");
        checkArgument(s.length() <= 19, "vendor number must be no more than 19 chars");
        this.vendorNumber = s;
      }

      public String toString() {
        return vendorNumber;
      }
    }

    public static class AddressLine implements ToStringSerializable {
        private static final Pattern ADDR_LINE_REGEX = Pattern.compile("[-#'.a-zA-Z0-9&\\s]+");
        private final String addrLine;

        public AddressLine(String unclean) {
            String s = unclean.split("\\R")[0]; // to handle those cases where street1 contains *entire* addr separated by newlines
            s = transliterator.transliterate(s);
            checkArgument(ADDR_LINE_REGEX.matcher(s).matches(), "address part must only contain alphanumeric, whitespace, or [-#'.&] chars");
            checkArgument(s.length() <= 35, "address part must be no longer than thirty-five chars");
            this.addrLine = s;
        }

        public String toString() {
            return addrLine;
        }
    }

    public static class Phone implements ToStringSerializable {
        private final String s;

        public Phone(String s) {
            checkArgument(ALPHANUMERIC_HYPHEN_REGEX.matcher(s).matches(), "phone number must contain only alphanumberic or hyphen characters");
            this.s = s;
        }

        public String toString() {
            return s;
        }
    }

    public static class City implements ToStringSerializable {
        private static final Pattern R = Pattern.compile("[-.a-zA-Z0-9\\s]+");
        private final String city;

        public City(String _city) {
            String city = transliterator.transliterate(_city);
            checkArgument(R.matcher(city).matches(), "city must only contain alphanumeric, hyphen, period, or whitespace chars");
            checkArgument(city.length() <= 35, "city name must be no longer than thirty-five chars");
            this.city = city;
        }

        public String toString() {
            return city;
        }
    }

    public interface PostalCode {}

    public static class USPostalCode implements PostalCode, ToStringSerializable {
        private static final Pattern zipPattern = Pattern.compile("\\d{5}(-\\d{4})?");
        private final String zipCode;

        public USPostalCode(String zipCode) {
            checkArgument(zipPattern.matcher(zipCode).matches(), "zip code must be either five digit or ZIP+4 format");
            this.zipCode = zipCode;
        }

        public String toString() {
            return zipCode;
        }
    }

    public static class Description implements ToStringSerializable {
        private final String description;

        public Description(String s) {
            checkArgument(isAlphanumericSpace(s), "description must contain only alphanumeric and whitespace chars");
            checkArgument(s.length() <= 30, "description must be no longer than thirty chars");
            this.description = s;
        }

        public String toString() {
            return description;
        }
    }

    public static class InvoiceDate implements ToStringSerializable {
        @Getter
        private final LocalDate date;

        public InvoiceDate(LocalDate d) {
            checkArgument(d != null, "invoice date cannot be blank or null");
            this.date = d;
        }

        public String toString() {
            return f.format(date);
        }
    }

    @RequiredArgsConstructor
    public enum State implements ToStringSerializable {
        AL("Alabama"),
        AK("Alaska"),
        AZ("Arizona"),
        AR("Arkansas"),
        CA("California"),
        CO("Colorado"),
        CT("Connecticut"),
        DE("Delaware"),
        DC("District of Columbia"),
        FL("Florida"),
        GA("Georgia"),
        HI("Hawaii"),
        ID("Idaho"),
        IL("Illinois"),
        IN("Indiana"),
        IA("Iowa"),
        KS("Kansas"),
        KY("Kentucky"),
        LA("Louisiana"),
        ME("Maine"),
        MT("Montana"),
        NE("Nebraska"),
        NV("Nevada"),
        NH("New Hampshire"),
        NJ("New Jersey"),
        NM("New Mexico"),
        NY("New York"),
        NC("North Carolina"),
        ND("North Dakota"),
        OH("Ohio"),
        OK("Oklahoma"),
        OR("Oregon"),
        MD("Maryland"),
        MA("Massachusetts"),
        MI("Michigan"),
        MN("Minnesota"),
        MS("Mississippi"),
        MO("Missouri"),
        PA("Pennsylvania"),
        RI("Rhode Island"),
        SC("South Carolina"),
        SD("South Dakota"),
        TN("Tennessee"),
        TX("Texas"),
        UT("Utah"),
        VT("Vermont"),
        VA("Virginia"),
        WA("Washington"),
        WV("West Virginia"),
        WI("Wisconsin"),
        WY("Wyoming");

        @Getter
        private final String name;
    }
}
