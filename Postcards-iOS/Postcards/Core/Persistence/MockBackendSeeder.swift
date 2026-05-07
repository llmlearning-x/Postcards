import Foundation
import SwiftData

@MainActor
enum MockBackendSeeder {
    static func seedIfNeeded(in context: ModelContext, calendar: Calendar = .current) {
        let descriptor = FetchDescriptor<Travel>()
        guard (try? context.fetchCount(descriptor)) == 0 else {
            return
        }

        let today = calendar.startOfDay(for: Date())
        let guangxiStart = calendar.date(byAdding: .day, value: -5, to: today) ?? today
        let guangxiEnd = calendar.date(byAdding: .day, value: 10, to: guangxiStart)
        let yunnanStart = date(year: 2024, month: 4, day: 1, calendar: calendar)
        let yunnanEnd = date(year: 2024, month: 4, day: 10, calendar: calendar)
        let shanghaiStart = date(year: 2024, month: 2, day: 10, calendar: calendar)
        let shanghaiEnd = date(year: 2024, month: 2, day: 13, calendar: calendar)
        let sichuanStart = date(year: 2023, month: 10, day: 2, calendar: calendar)
        let sichuanEnd = date(year: 2023, month: 10, day: 9, calendar: calendar)

        let guangxi = makeTravel(
            title: "广西之旅",
            destination: "南宁",
            startDate: guangxiStart,
            endDate: guangxiEnd,
            status: .ongoing,
            isCurrent: true
        )
        let yunnan = makeTravel(
            title: "云南之旅",
            destination: "云南",
            startDate: yunnanStart,
            endDate: yunnanEnd,
            status: .completed,
            isCurrent: false
        )
        let shanghai = makeTravel(
            title: "上海之旅",
            destination: "上海",
            startDate: shanghaiStart,
            endDate: shanghaiEnd,
            status: .completed,
            isCurrent: false
        )
        let sichuan = makeTravel(
            title: "川西之旅",
            destination: "川西",
            startDate: sichuanStart,
            endDate: sichuanEnd,
            status: .completed,
            isCurrent: false
        )

        [guangxi, yunnan, shanghai, sichuan].forEach(context.insert)

        let citySamples = mockCities()
        for index in 0..<128 {
            let city = citySamples[index % citySamples.count]
            let travel = travelForPostcard(index: index, guangxi: guangxi, yunnan: yunnan, shanghai: shanghai, sichuan: sichuan)
            let recordedAt = calendar.date(byAdding: .day, value: index % 10, to: travel.startDate) ?? travel.startDate
            let postcard = Postcard(locationName: city.locationName, recordedAt: recordedAt)
            postcard.travel = travel
            postcard.travelID = travel.id
            postcard.city = city.city
            postcard.country = "中国"
            postcard.locationLat = city.latitude
            postcard.locationLng = city.longitude
            postcard.weatherCondition = ["晴", "多云", "小雨", "晚风"][index % 4]
            postcard.weatherTemp = Double(18 + index % 12)
            postcard.note = city.note
            postcard.tags = city.tags
            postcard.isFavorite = index < 86
            context.insert(postcard)
        }

        do {
            try context.save()
        } catch {
            assertionFailure("Failed to seed mock backend data: \(error.localizedDescription)")
        }
    }

    private static func makeTravel(
        title: String,
        destination: String,
        startDate: Date,
        endDate: Date?,
        status: Travel.TravelStatus,
        isCurrent: Bool
    ) -> Travel {
        let travel = Travel(title: title, destination: destination, startDate: startDate, isCurrent: isCurrent)
        travel.endDate = endDate
        travel.status = status
        travel.createdAt = startDate
        travel.updatedAt = Date()
        return travel
    }

    private static func travelForPostcard(index: Int, guangxi: Travel, yunnan: Travel, shanghai: Travel, sichuan: Travel) -> Travel {
        if index < 56 {
            return guangxi
        }
        if index < 88 {
            return yunnan
        }
        if index < 108 {
            return shanghai
        }
        return sichuan
    }

    private static func date(year: Int, month: Int, day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    private static func mockCities() -> [MockCity] {
        [
            MockCity("南宁", "南宁市", 22.8170, 108.3669, "抵达绿城，开启旅程", ["绿城", "启程"]),
            MockCity("阳朔", "遇龙河", 24.7785, 110.4966, "竹筏漂流，如诗如画", ["山水", "河流"]),
            MockCity("龙脊", "龙脊梯田", 25.7590, 110.1230, "层层叠叠，大地指纹", ["梯田", "日落"]),
            MockCity("北海", "北海银滩", 21.4811, 109.1202, "海风吹过最后一张明信片", ["海岸", "银滩"]),
            MockCity("桂林", "象鼻山晨景", 25.2736, 110.2900, "山影落在江面上", ["桂林", "晨景"]),
            MockCity("柳州", "柳州老街", 24.3264, 109.4281, "夜市灯火很暖", ["老街", "夜色"]),
            MockCity("昆明", "昆明翠湖", 25.0389, 102.7183, "湖边风很轻", ["翠湖", "春城"]),
            MockCity("大理", "洱海", 25.6065, 100.2676, "云从海面慢慢散开", ["洱海", "骑行"]),
            MockCity("丽江", "丽江古城", 26.8768, 100.2320, "石板路寄来旧时光", ["古城", "纳西"]),
            MockCity("香格里拉", "松赞林寺", 27.8297, 99.7068, "金色屋顶在云下闪光", ["雪山", "寺院"]),
            MockCity("上海", "外滩", 31.2400, 121.4900, "霓虹倒映在江面", ["外滩", "夜景"]),
            MockCity("南京路", "南京路步行街", 31.2352, 121.4747, "人潮像一封很长的信", ["街道", "城市"]),
            MockCity("迪士尼", "上海迪士尼", 31.1443, 121.6579, "烟花把一天盖上邮戳", ["乐园", "烟花"]),
            MockCity("成都", "宽窄巷子", 30.6760, 104.0600, "慢下来喝一碗盖碗茶", ["成都", "茶馆"]),
            MockCity("四姑娘山", "双桥沟", 31.0333, 102.9000, "雪山像未寄出的信纸", ["雪山", "徒步"]),
            MockCity("稻城亚丁", "洛绒牛场", 28.4380, 100.3100, "风穿过高原草甸", ["高原", "远方"]),
            MockCity("万宁", "日月湾", 18.7940, 110.3080, "浪花把邮票边缘打湿", ["海浪", "冲浪"]),
            MockCity("杭州", "西湖", 30.2460, 120.1500, "湖光像旧相册的封面", ["西湖", "江南"]),
            MockCity("苏州", "平江路", 31.3150, 120.6290, "小桥流水慢慢走", ["江南", "古街"]),
            MockCity("南京", "玄武湖", 32.0710, 118.7920, "城墙外的风很清亮", ["城墙", "湖"]),
            MockCity("厦门", "鼓浪屿", 24.4475, 118.0679, "钢琴声从小巷寄出", ["海岛", "小巷"]),
            MockCity("福州", "三坊七巷", 26.0830, 119.2965, "古厝里有温热的光", ["古厝", "街巷"]),
            MockCity("青岛", "栈桥", 36.0610, 120.3200, "海鸥飞过红瓦屋顶", ["海滨", "红瓦"]),
            MockCity("威海", "环海路", 37.5130, 122.1200, "沿海公路像蓝色邮路", ["海岸", "公路"]),
            MockCity("北京", "故宫", 39.9163, 116.3972, "红墙给旅程盖章", ["故宫", "城市"]),
            MockCity("西安", "城墙", 34.2658, 108.9541, "夕阳落在城砖上", ["古城", "夕阳"]),
            MockCity("兰州", "黄河铁桥", 36.0671, 103.8343, "黄河边寄出一阵风", ["黄河", "桥"]),
            MockCity("敦煌", "鸣沙山", 40.1410, 94.6618, "沙丘像金色邮戳", ["沙漠", "日落"]),
            MockCity("拉萨", "布达拉宫", 29.6578, 91.1169, "阳光从高处寄来", ["高原", "宫殿"]),
            MockCity("重庆", "洪崖洞", 29.5630, 106.5750, "灯火沿山城层层打开", ["山城", "夜景"]),
            MockCity("贵阳", "甲秀楼", 26.5760, 106.7240, "桥上风吹起信纸", ["楼阁", "河畔"]),
            MockCity("长沙", "橘子洲", 28.1960, 112.9730, "江风把邮路吹长", ["湘江", "洲头"]),
            MockCity("武汉", "黄鹤楼", 30.5450, 114.3000, "楼影落在长江边", ["长江", "楼阁"]),
            MockCity("南昌", "滕王阁", 28.6820, 115.8810, "晚霞写满阁楼", ["晚霞", "古阁"]),
            MockCity("广州", "沙面", 23.1090, 113.2390, "老建筑里有树影", ["岭南", "街区"]),
            MockCity("深圳", "盐田海滨", 22.5550, 114.2360, "城市尽头是海", ["城市", "海滨"]),
            MockCity("珠海", "情侣路", 22.2560, 113.5820, "海风沿路投递", ["海风", "灯塔"]),
            MockCity("香港", "维港", 22.2930, 114.1690, "天际线亮成邮票", ["维港", "夜景"]),
            MockCity("澳门", "大三巴", 22.1970, 113.5400, "石阶上有旧时光", ["街巷", "建筑"]),
            MockCity("三亚", "亚龙湾", 18.2280, 109.6380, "海水透明得像信封", ["海岛", "阳光"]),
            MockCity("腾冲", "和顺古镇", 25.0170, 98.4870, "火山脚下的慢日子", ["古镇", "温泉"]),
            MockCity("普洱", "茶山", 22.8250, 100.9660, "茶香贴上邮票", ["茶山", "雨林"])
        ]
    }
}

private struct MockCity {
    let city: String
    let locationName: String
    let latitude: Double
    let longitude: Double
    let note: String
    let tags: [String]

    init(_ city: String, _ locationName: String, _ latitude: Double, _ longitude: Double, _ note: String, _ tags: [String]) {
        self.city = city
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.note = note
        self.tags = tags
    }
}
