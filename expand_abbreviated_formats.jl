function expand_abbreviated_formats(inputdir, outputdir)
    for file in readdir(inputdir)
        open(joinpath(outputdir, file), "w") do out
            print(out, readstring(`thru $(joinpath(inputdir, file))`))
        end
    end
end

expand_abbreviated_formats("iRb_v1-0", "iRb_thru")
