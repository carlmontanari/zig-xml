const std = @import("std");
const Build = std.Build;
const Step = Build.Step;

pub fn build(b: *Build) !void {
    const xml = b.dependency("xml", .{}).module("xml");

    const bench_scanner = addBench(b, "scanner");
    bench_scanner.addModule("xml", xml);
    bench_scanner.linkLibC();

    const bench_token_reader = addBench(b, "token_reader");
    bench_token_reader.addModule("xml", xml);
    bench_token_reader.linkLibC();

    const bench_reader = addBench(b, "reader");
    bench_reader.addModule("xml", xml);
    bench_reader.linkLibC();

    const libxml2 = b.dependency("libxml2", .{
        .optimize = .ReleaseFast,
        .iconv = false,
        .lzma = false,
        .zlib = false,
    });
    const bench_libxml2 = addBench(b, "libxml2");
    bench_libxml2.linkLibrary(libxml2.artifact("xml2"));

    const yxml = b.dependency("yxml", .{});
    const bench_yxml = addBench(b, "yxml");
    bench_yxml.linkLibC();
    bench_yxml.addCSourceFile(.{ .file = yxml.path("yxml.c"), .flags = &.{} });
    bench_yxml.addIncludePath(yxml.path("."));

    const mxml = b.dependency("mxml", .{});
    const bench_mxml = addBench(b, "mxml");
    bench_mxml.linkLibC();
    bench_mxml.addCSourceFiles(.{
        .dependency = mxml,
        .files = &.{
            "mxml-attr.c",
            "mxml-entity.c",
            "mxml-file.c",
            "mxml-get.c",
            "mxml-index.c",
            "mxml-node.c",
            "mxml-private.c",
            "mxml-search.c",
            "mxml-set.c",
            "mxml-string.c",
        },
    });
    bench_mxml.addIncludePath(mxml.path("."));
    bench_mxml.addIncludePath(.{ .path = "lib/mxml-config" });
}

fn addBench(b: *Build, name: []const u8) *Step.Compile {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = b.fmt("src/{s}.zig", .{name}) },
        .optimize = .ReleaseFast,
    });
    b.installArtifact(exe);
    return exe;
}
