let
    // 1. Get the min date from your fact table
    MinDate = List.Min(#"YourFactTable"[Date]),

    // 2. Use today's date as the end date
    MaxDate = DateTime.Date(DateTime.LocalNow()),

    // 3. Normalize the range
    StartDate = #date(Date.Year(MinDate), Date.Month(MinDate), Date.Day(MinDate)),
    EndDate = MaxDate,

    // 4. Generate the date list
    DateList = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),

    // 5. Convert to table
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),

    // 6. Add date attributes
    AddYear = Table.AddColumn(DateTable, "Year", each Date.Year([Date]), Int64.Type),
    AddMonth = Table.AddColumn(AddYear, "Month", each Date.Month([Date]), Int64.Type),
    AddMonthName = Table.AddColumn(AddMonth, "Month Name", each Date.ToText([Date], "MMMM")),
    AddMonthShort = Table.AddColumn(AddMonthName, "Month Short", each Date.ToText([Date], "MMM")),
    AddDay = Table.AddColumn(AddMonthShort, "Day", each Date.Day([Date]), Int64.Type),
    AddDayName = Table.AddColumn(AddDay, "Day Name", each Date.ToText([Date], "dddd")),
    AddDayShort = Table.AddColumn(AddDayName, "Day Short", each Date.ToText([Date], "ddd")),
    AddQuarter = Table.AddColumn(AddDayShort, "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
    AddWeekOfYear = Table.AddColumn(AddQuarter, "Week of Year", each Date.WeekOfYear([Date]), Int64.Type),
    AddWeekOfMonth = Table.AddColumn(AddWeekOfYear, "Week of Month", each Date.WeekOfMonth([Date]), Int64.Type),
    AddIsWeekend = Table.AddColumn(AddWeekOfMonth, "Is Weekend", each Date.DayOfWeek([Date], Day.Monday) > 4, type logical),

    // 7. Reorder columns
    FinalTable = Table.ReorderColumns(AddIsWeekend, {
        "Date", "Year", "Month", "Month Name", "Month Short", 
        "Quarter", "Day", "Day Name", "Day Short", 
        "Week of Year", "Week of Month", "Is Weekend"
    })
in
    FinalTable
