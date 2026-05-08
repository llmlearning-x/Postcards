import { Travel, TravelStatus } from './Travel';
import { Postcard } from './Postcard';

class MockCity {
  city: string;
  locationName: string;
  latitude: number;
  longitude: number;
  note: string;
  tags: string[];

  constructor(city: string, locationName: string, latitude: number, longitude: number, note: string, tags: string[]) {
    this.city = city;
    this.locationName = locationName;
    this.latitude = latitude;
    this.longitude = longitude;
    this.note = note;
    this.tags = tags;
  }
}

function dateDaysAgo(days: number): number {
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() - days);
  return d.getTime();
}

function dateFrom(year: number, month: number, day: number): number {
  const d = new Date(year, month - 1, day);
  d.setHours(0, 0, 0, 0);
  return d.getTime();
}

export class MockBackendSeeder {
  static seed(travels: Travel[], postcards: Postcard[]) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const guangxi = new Travel('广西之旅', '南宁', dateDaysAgo(5), true);
    guangxi.endDate = dateDaysAgo(-10);
    guangxi.status = TravelStatus.ONGOING;

    const yunnan = new Travel('云南之旅', '云南', dateFrom(2024, 4, 1), false);
    yunnan.endDate = dateFrom(2024, 4, 10);
    yunnan.status = TravelStatus.COMPLETED;

    const shanghai = new Travel('上海之旅', '上海', dateFrom(2024, 2, 10), false);
    shanghai.endDate = dateFrom(2024, 2, 13);
    shanghai.status = TravelStatus.COMPLETED;

    const sichuan = new Travel('川西之旅', '川西', dateFrom(2023, 10, 2), false);
    sichuan.endDate = dateFrom(2023, 10, 9);
    sichuan.status = TravelStatus.COMPLETED;

    travels.push(guangxi, yunnan, shanghai, sichuan);

    const citySamples = MockBackendSeeder.mockCities();
    for (let i = 0; i < 128; i++) {
      const city = citySamples[i % citySamples.length];
      const travel = MockBackendSeeder.travelForIndex(i, guangxi, yunnan, shanghai, sichuan);
      const recordedAt = travel.startDate + (i % 10) * 24 * 60 * 60 * 1000;
      const postcard = new Postcard(city.locationName, recordedAt);
      postcard.travelID = travel.id;
      postcard.city = city.city;
      postcard.country = '中国';
      postcard.locationLat = city.latitude;
      postcard.locationLng = city.longitude;
      postcard.weatherCondition = ['晴', '多云', '小雨', '晚风'][i % 4];
      postcard.weatherTemp = 18 + (i % 12);
      postcard.note = city.note;
      postcard.tags = city.tags;
      postcard.isFavorite = i < 86;
      postcards.push(postcard);
    }
  }

  private static travelForIndex(index: number, guangxi: Travel, yunnan: Travel, shanghai: Travel, sichuan: Travel): Travel {
    if (index < 56) return guangxi;
    if (index < 88) return yunnan;
    if (index < 108) return shanghai;
    return sichuan;
  }

  private static mockCities(): MockCity[] {
    return [
      new MockCity('南宁', '南宁市', 22.8170, 108.3669, '抵达绿城，开启旅程', ['绿城', '启程']),
      new MockCity('阳朔', '遇龙河', 24.7785, 110.4966, '竹筏漂流，如诗如画', ['山水', '河流']),
      new MockCity('龙脊', '龙脊梯田', 25.7590, 110.1230, '层层叠叠，大地指纹', ['梯田', '日落']),
      new MockCity('北海', '北海银滩', 21.4811, 109.1202, '海风吹过最后一张明信片', ['海岸', '银滩']),
      new MockCity('桂林', '象鼻山晨景', 25.2736, 110.2900, '山影落在江面上', ['桂林', '晨景']),
      new MockCity('柳州', '柳州老街', 24.3264, 109.4281, '夜市灯火很暖', ['老街', '夜色']),
      new MockCity('昆明', '昆明翠湖', 25.0389, 102.7183, '湖边风很轻', ['翠湖', '春城']),
      new MockCity('大理', '洱海', 25.6065, 100.2676, '云从海面慢慢散开', ['洱海', '骑行']),
      new MockCity('丽江', '丽江古城', 26.8768, 100.2320, '石板路寄来旧时光', ['古城', '纳西']),
      new MockCity('香格里拉', '松赞林寺', 27.8297, 99.7068, '金色屋顶在云下闪光', ['雪山', '寺院']),
      new MockCity('上海', '外滩', 31.2400, 121.4900, '霓虹倒映在江面', ['外滩', '夜景']),
      new MockCity('南京路', '南京路步行街', 31.2352, 121.4747, '人潮像一封很长的信', ['街道', '城市']),
      new MockCity('迪士尼', '上海迪士尼', 31.1443, 121.6579, '烟花把一天盖上邮戳', ['乐园', '烟花']),
      new MockCity('成都', '宽窄巷子', 30.6760, 104.0600, '慢下来喝一碗盖碗茶', ['成都', '茶馆']),
      new MockCity('四姑娘山', '双桥沟', 31.0333, 102.9000, '雪山像未寄出的信纸', ['雪山', '徒步']),
      new MockCity('稻城亚丁', '洛绒牛场', 28.4380, 100.3100, '风穿过高原草甸', ['高原', '远方']),
      new MockCity('万宁', '日月湾', 18.7940, 110.3080, '浪花把邮票边缘打湿', ['海浪', '冲浪']),
      new MockCity('杭州', '西湖', 30.2460, 120.1500, '湖光像旧相册的封面', ['西湖', '江南']),
      new MockCity('苏州', '平江路', 31.3150, 120.6290, '小桥流水慢慢走', ['江南', '古街']),
      new MockCity('南京', '玄武湖', 32.0710, 118.7920, '城墙外的风很清亮', ['城墙', '湖']),
      new MockCity('厦门', '鼓浪屿', 24.4475, 118.0679, '钢琴声从小巷寄出', ['海岛', '小巷']),
      new MockCity('福州', '三坊七巷', 26.0830, 119.2965, '古厝里有温热的光', ['古厝', '街巷']),
      new MockCity('青岛', '栈桥', 36.0610, 120.3200, '海鸥飞过红瓦屋顶', ['海滨', '红瓦']),
      new MockCity('威海', '环海路', 37.5130, 122.1200, '沿海公路像蓝色邮路', ['海岸', '公路']),
      new MockCity('北京', '故宫', 39.9163, 116.3972, '红墙给旅程盖章', ['故宫', '城市']),
      new MockCity('西安', '城墙', 34.2658, 108.9541, '夕阳落在城砖上', ['古城', '夕阳']),
      new MockCity('兰州', '黄河铁桥', 36.0671, 103.8343, '黄河边寄出一阵风', ['黄河', '桥']),
      new MockCity('敦煌', '鸣沙山', 40.1410, 94.6618, '沙丘像金色邮戳', ['沙漠', '日落']),
      new MockCity('拉萨', '布达拉宫', 29.6578, 91.1169, '阳光从高处寄来', ['高原', '宫殿']),
      new MockCity('重庆', '洪崖洞', 29.5630, 106.5750, '灯火沿山城层层打开', ['山城', '夜景']),
      new MockCity('贵阳', '甲秀楼', 26.5760, 106.7240, '桥上风吹起信纸', ['楼阁', '河畔']),
      new MockCity('长沙', '橘子洲', 28.1960, 112.9730, '江风把邮路吹长', ['湘江', '洲头']),
      new MockCity('武汉', '黄鹤楼', 30.5450, 114.3000, '楼影落在长江边', ['长江', '楼阁']),
      new MockCity('南昌', '滕王阁', 28.6820, 115.8810, '晚霞写满阁楼', ['晚霞', '古阁']),
      new MockCity('广州', '沙面', 23.1090, 113.2390, '老建筑里有树影', ['岭南', '街区']),
      new MockCity('深圳', '盐田海滨', 22.5550, 114.2360, '城市尽头是海', ['城市', '海滨']),
      new MockCity('珠海', '情侣路', 22.2560, 113.5820, '海风沿路投递', ['海风', '灯塔']),
      new MockCity('香港', '维港', 22.2930, 114.1690, '天际线亮成邮票', ['维港', '夜景']),
      new MockCity('澳门', '大三巴', 22.1970, 113.5400, '石阶上有旧时光', ['街巷', '建筑']),
      new MockCity('三亚', '亚龙湾', 18.2280, 109.6380, '海水透明得像信封', ['海岛', '阳光']),
      new MockCity('腾冲', '和顺古镇', 25.0170, 98.4870, '火山脚下的慢日子', ['古镇', '温泉']),
      new MockCity('普洱', '茶山', 22.8250, 100.9660, '茶香贴上邮票', ['茶山', '雨林'])
    ];
  }
}
