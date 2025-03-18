<!DOCTYPE html>
<html>

<head>
    <title>Material List</title>
    <style>
        :root {
            --primary-color: #1f3c73;
            --inner-border-color: #bbd8ec;
        }

        body {
            font-family: Lato, sans-serif;
            padding: 24px;
            font-size: 9px;
            box-sizing: border-box;
        }

        .header {
            display: flex;
            justify-content: space-between;
            padding-bottom: 12px;
        }

        .content {
            padding-bottom: 12px;
        }

        .footer {
            display: flex;
            justify-content: right;
        }

        .title,
        .label {
            font-weight: bold;
        }

        .title {
            font-size: 12px;
            padding-bottom: 8px;
        }

        .label,
        .field-value {
            font-size: 9px;
        }

        .address div,
        .field {
            padding-bottom: 4px;
        }

        .left {
            text-align: left;
        }

        .right {
            text-align: right;
        }

        /* Ship to box */
        .ship-to {
            border-width: 1px;
            border-style: solid;
            border-color: var(--primary-color);
            width: 266px;
            text-align: left;
            display: grid;
            grid-template-columns: auto 1fr;
            grid-template-rows: auto repeat(3, auto);
            gap: 4px 16px;
            max-width: 266px;
            padding-bottom: 8px;
        }

        .ship-to-header {
            grid-column: span 2;
            background-color: #e0e0e0;
            padding: 4px;
        }

        .ship-to .label {
            text-align: right;
            font-weight: bold;
            padding-left: 8px;
        }

        .ship-to .field-value {
            text-align: left;
        }

        /* Parts Table */
        table {
            width: 100%;
            border-collapse: collapse;
            border: 2px solid var(--primary-color);
        }

        th,
        td {
            border: 1px solid var(--inner-border-color);
            padding: 8px;
            text-align: left;
            vertical-align: top;
        }

        th {
            background-color: var(--primary-color);
            color: white;
        }

        tbody tr {
            background-color: white;
        }

        .spacer-row td {
            background-color: #FAFAFA;
            border: none;
            height: 10px;
        }

        @page {
            @bottom-right {
                content: "Page " counter(page) " of " counter(pages);
                font-family: Lato, sans-serif;
                font-size: 9px;
                font-weight: bold;
            }
        }
    </style>
</head>

<body>
<div class="header">
    <div class="left">
        <div class="title">Blue Raven Solar</div>
        <div class="address">
            <div>1403 N Research Way, Building J</div>
            <div>Orem, UT 84097</div>
            <div>800-377-4480</div>
        </div>
        <br/>
        <div class="field">
            <span class="label">Final Design Log Number </span>
            <#if designLogNumber??>
            <span class="field-value">${designLogNumber?c}</span>
            </#if>
        </div>
        <div class="field">
            <span class="label">Permit Pack Log Number </span>
            <#if permitPackLogNumber??><span class="field-value">${permitPackLogNumber?c}</span></#if>
        </div>
    </div>
    <div class="right">
        <div class="field">
            <span class="label">Project Id </span>
            <#if projectId??><span class="field-value">${projectId?c}</span></#if>
        </div>
        <div class="field">
            <span class="label">Date </span>
            <#if date??><span class="field-value">${date}</span></#if>
        </div>
        <div class="ship-to">
            <div class="ship-to-header">Ship to</div>

            <div class="label">Name</div>
            <#if shipToName??><div class="field-value">${shipToName}</div></#if>

            <div class="label">Address</div>
            <div class="field-value">
                ${shipToAddress?no_esc}
            </div>

            <div class="label">Phone Number</div>
            <#if shipToPhoneNumber??><div class="field-value">${shipToPhoneNumber}</div></#if>
        </div>
    </div>
</div>

<div class="content">
    <table>
        <thead>
        <tr>
            <th>Item</th>
            <th>Quantity</th>
            <th>Part Number</th>
            <th>Description</th>
        </tr>
        </thead>
        <tbody>
        <#list parts?keys as objectType>
            <#assign details = parts[objectType] />

            <tr>
                <td rowspan="${details?size}">${objectType}</td>
                <td>${details[0].quantity}</td>
                <td>${details[0].partNumber}</td>
                <td>${details[0].description}</td>
            </tr>

            <#list details[1..] as detail>
            <tr>
                <td>${detail.quantity}</td>
                <td>${detail.partNumber}</td>
                <td>${detail.description}</td>
            </tr>
            </#list>
            <#if !objectType?is_last>
                <tr class="spacer-row">
                    <td colspan="4"></td>
                </tr>
            </#if>
        </#list>
        </tbody>
    </table>
</div>

</body>

</html>
