extern crate tdms;

use std::env;
use std::path::Path;
use tdms::data_type::TdmsDataType;
use tdms::TDMSFile;

fn main() {
    // open and parse the TDMS file, passing in metadata false will mean the entire file is
    // read into memory, not just the metadata
    // let path = Path::new("data/JJH15/075_UKA+ACL_flex-ext_1BW_5IE_90AP/Data/075_UKA+ACL_flex-ext_1BW_5IE_90AP_5Nm_int_flex_1of1_1_Main_processed.tdms");
    let args: Vec<_> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} <path_to_tdms_file>", args[0]);
        std::process::exit(1);
    }
    let path = Path::new(&args[1]);
    let file = match TDMSFile::from_path(path) {
        Ok(f) => f,
        Err(e) => panic!("{:?}", e),
    };

    // fetch groups
    let groups = file.groups();
    // let lvdts: Vec<&str> = groups
    //     .iter()
    //     .filter(|c| c.to_lowercase().contains("lvdt"))
    //     .map(|f| f.as_str())
    //     .collect();
    let test: Vec<_> = groups
        .iter()
        .filter(|c| c.to_lowercase().contains("lvdt"))
        .map(|c| file.channels(&c))
        .flat_map(|c| {
            c.values()
                .cloned()
                .map(|channel| match channel.data_type {
                    TdmsDataType::DoubleFloat(_) => file.channel_data_double_float(channel),
                    _ => panic!("this lib is shit"),
                })
                .collect::<Vec<_>>()
        })
    .collect();

    println!("{:#?}", test);
    // println!("{:#?}", channels.last());

    //
    // for group in groups {
    //     // fetch an IndexSet of the group's channels
    //     let channels = file.channels(&group);
    //
    //     let mut i = 0;
    //     for (_, channel) in channels {
    //         // once you know the channel's full path (group + channel) you can ask for the full
    //         // channel object. In order to fetch a channel you must call the proper channel func
    //         // depending on your data type. Currently this feature is unimplemented but the method
    //         // of calling this is set down for future changes
    //         let full_channel = match channel.data_type {
    //             // the returned full channel is an iterator over raw data
    //             TdmsDataType::DoubleFloat(_) => file.channel_data_double_float(channel),
    //             _ => {
    //                 panic!("{}", "channel for data type unimplemented")
    //             }
    //         };
    //
    //         let mut full_channel_iterator = match full_channel {
    //             Ok(i) => i,
    //             Err(e) => {
    //                 panic!("{:?}", e)
    //             }
    //         };
    //
    //         println!("{:?}", full_channel_iterator.count());
    //
    //         i += 1;
    //     }
    // }
}
